import 'package:uuid/uuid.dart';

import '../../../core/customers/customers_repository.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/sync_queue.dart';
import '../../../core/products/products_repository.dart';
import '../domain/entities/cart_line.dart';
import '../domain/entities/sale.dart';

const _uuid = Uuid();

class SalesRepository {
  final AppDatabase _appDatabase;
  final ProductsRepository _productsRepository;
  final CustomersRepository _customersRepository;

  SalesRepository(this._appDatabase, this._productsRepository, this._customersRepository);

  /// Confirma una venta: inserta la venta y sus líneas, descuenta inventario,
  /// aplica el cargo a fiado si corresponde, y encola todo para sincronizar
  /// — en UNA sola transacción local, así nunca queda a medias.
  Future<Sale> checkout({
    required List<CartLine> cart,
    required PaymentMethod paymentMethod,
    String? customerId,
    double? receivedAmount,
    double? changeAmount,
  }) async {
    final db = await _appDatabase.database;
    final saleId = _uuid.v4();
    final total = cart.fold<double>(0, (sum, l) => sum + l.lineTotal);
    final sale = Sale(
      id: saleId,
      total: total,
      paymentMethod: paymentMethod,
      customerId: customerId,
      receivedAmount: receivedAmount,
      changeAmount: changeAmount,
      createdAt: DateTime.now(),
    );

    await db.transaction((txn) async {
      await txn.insert('sales', sale.toMap());
      await enqueueSync(
        txn,
        entityType: 'sale',
        entityId: saleId,
        operation: 'create',
        payload: sale.toMap(),
      );

      for (final line in cart) {
        final item = SaleItem(
          id: _uuid.v4(),
          saleId: saleId,
          productId: line.productId,
          productName: line.name,
          quantity: line.quantity,
          unitPrice: line.unitPrice,
          lineTotal: line.lineTotal,
        );
        await txn.insert('sale_items', item.toMap());
        if (line.productId != null) {
          await _productsRepository.adjustStock(txn, line.productId!, -line.quantity);
        }
      }

      if (paymentMethod == PaymentMethod.fiado && customerId != null) {
        await _customersRepository.chargeSaleOnCredit(
          txn,
          customerId: customerId,
          amount: total,
          saleId: saleId,
        );
      }
    });

    return sale.copyWithItems(
      cart
          .map((l) => SaleItem(
                id: _uuid.v4(),
                saleId: saleId,
                productId: l.productId,
                productName: l.name,
                quantity: l.quantity,
                unitPrice: l.unitPrice,
                lineTotal: l.lineTotal,
              ))
          .toList(),
    );
  }

  Future<List<Sale>> getToday() async {
    final db = await _appDatabase.database;
    final startOfDay = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
    final rows = await db.query(
      'sales',
      where: 'created_at >= ?',
      whereArgs: [startOfDay.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return rows.map(Sale.fromMap).toList();
  }

  Future<List<Sale>> getAll() async {
    final db = await _appDatabase.database;
    final rows = await db.query('sales', orderBy: 'created_at DESC');
    return rows.map(Sale.fromMap).toList();
  }

  Future<List<SaleItem>> getItems(String saleId) async {
    final db = await _appDatabase.database;
    final rows = await db.query('sale_items', where: 'sale_id = ?', whereArgs: [saleId]);
    return rows.map(SaleItem.fromMap).toList();
  }
}

extension on Sale {
  Sale copyWithItems(List<SaleItem> items) => Sale(
        id: id,
        total: total,
        paymentMethod: paymentMethod,
        customerId: customerId,
        receivedAmount: receivedAmount,
        changeAmount: changeAmount,
        createdAt: createdAt,
        items: items,
      );
}
