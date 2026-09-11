import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/sync_queue.dart';
import 'entities/customer.dart';

const _uuid = Uuid();

/// Clientes fiado y sus movimientos — transversal: lo usa tanto la feature
/// de fiados (listado/detalle) como la de ventas (cobrar a crédito).
class CustomersRepository {
  final AppDatabase _appDatabase;

  CustomersRepository(this._appDatabase);

  Future<List<Customer>> getAll() async {
    final db = await _appDatabase.database;
    final rows = await db.query('fiado_customers', orderBy: 'name ASC');
    return rows.map(Customer.fromMap).toList();
  }

  double totalPending(List<Customer> customers) =>
      customers.fold<double>(0, (sum, c) => sum + c.balance);

  /// Pagos de fiado recibidos hoy, con el nombre del cliente — usado por el
  /// feed de actividad reciente del dashboard.
  Future<List<Map<String, dynamic>>> getTodayPayments() async {
    final db = await _appDatabase.database;
    final startOfDay = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0).toIso8601String();
    return db.rawQuery('''
      SELECT m.amount AS amount, m.created_at AS created_at, c.name AS customer_name
      FROM fiado_movements m
      JOIN fiado_customers c ON m.customer_id = c.id
      WHERE m.type = 'pago' AND m.created_at >= ?
      ORDER BY m.created_at DESC
    ''', [startOfDay]);
  }

  Future<Customer?> getById(String id) async {
    final db = await _appDatabase.database;
    final rows = await db.query('fiado_customers', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Customer.fromMap(rows.first);
  }

  Future<List<FiadoMovement>> getMovements(String customerId) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'fiado_movements',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'created_at DESC',
    );
    return rows.map(FiadoMovement.fromMap).toList();
  }

  Future<void> addCustomer(String name) async {
    final db = await _appDatabase.database;
    final customer = Customer(id: _uuid.v4(), name: name, balance: 0, createdAt: DateTime.now());
    await db.transaction((txn) async {
      await txn.insert('fiado_customers', customer.toMap());
      await enqueueSync(
        txn,
        entityType: 'fiado_customer',
        entityId: customer.id,
        operation: 'create',
        payload: customer.toMap(),
      );
    });
  }

  /// Registra una venta a crédito — se llama dentro de la transacción de la
  /// venta (ver `SalesRepository.checkout`), nunca de forma aislada.
  Future<void> chargeSaleOnCredit(
    Transaction txn, {
    required String customerId,
    required double amount,
    required String saleId,
  }) async {
    await txn.rawUpdate(
      'UPDATE fiado_customers SET balance = balance + ? WHERE id = ?',
      [amount, customerId],
    );
    final movement = {
      'id': _uuid.v4(),
      'customer_id': customerId,
      'type': FiadoMovementType.compra.name,
      'amount': amount,
      'note': 'Venta #${saleId.substring(0, 8)}',
      'payment_method': null,
      'sale_id': saleId,
      'created_at': DateTime.now().toIso8601String(),
    };
    await txn.insert('fiado_movements', movement);
    await enqueueSync(
      txn,
      entityType: 'fiado_movement',
      entityId: movement['id'] as String,
      operation: 'create',
      payload: movement,
    );
  }

  Future<void> registerPayment({
    required String customerId,
    required double amount,
    required String paymentMethod,
  }) async {
    final db = await _appDatabase.database;
    final movementId = _uuid.v4();
    await db.transaction((txn) async {
      await txn.rawUpdate(
        'UPDATE fiado_customers SET balance = balance - ? WHERE id = ?',
        [amount, customerId],
      );
      final movement = {
        'id': movementId,
        'customer_id': customerId,
        'type': FiadoMovementType.pago.name,
        'amount': amount,
        'note': null,
        'payment_method': paymentMethod,
        'sale_id': null,
        'created_at': DateTime.now().toIso8601String(),
      };
      await txn.insert('fiado_movements', movement);
      await enqueueSync(
        txn,
        entityType: 'fiado_movement',
        entityId: movementId,
        operation: 'create',
        payload: movement,
      );
    });
  }
}
