import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/sync_queue.dart';
import 'entities/product.dart';

class ProductsRepository {
  final AppDatabase _appDatabase;

  ProductsRepository(this._appDatabase);

  Future<List<Product>> getAll() async {
    final db = await _appDatabase.database;
    final rows = await db.query('products', orderBy: 'name ASC');
    return rows.map(Product.fromMap).toList();
  }

  Future<void> insert(Product product) async {
    final db = await _appDatabase.database;
    await db.transaction((txn) async {
      await txn.insert('products', product.toMap());
      await enqueueSync(
        txn,
        entityType: 'product',
        entityId: product.id,
        operation: 'create',
        payload: product.toMap(),
      );
    });
  }

  Future<void> update(Product product) async {
    final db = await _appDatabase.database;
    await db.transaction((txn) async {
      await txn.update(
        'products',
        product.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
      await enqueueSync(
        txn,
        entityType: 'product',
        entityId: product.id,
        operation: 'update',
        payload: product.toMap(),
      );
    });
  }

  /// Descuenta stock dentro de una transacción existente (usado al vender).
  Future<void> adjustStock(Transaction txn, String productId, double delta) async {
    final rows = await txn.query('products', where: 'id = ?', whereArgs: [productId]);
    if (rows.isEmpty) return;
    final current = (rows.first['stock'] as num?)?.toDouble();
    if (current == null) return;
    await txn.update(
      'products',
      {'stock': current + delta, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }
}
