import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/sync_queue.dart';
import '../domain/entities/expense.dart';

const _uuid = Uuid();

class ExpensesRepository {
  final AppDatabase _appDatabase;

  ExpensesRepository(this._appDatabase);

  Future<void> add({required double amount, required String concept, required String category}) async {
    final db = await _appDatabase.database;
    final expense = Expense(id: _uuid.v4(), amount: amount, concept: concept, category: category, createdAt: DateTime.now());
    await db.transaction((txn) async {
      await txn.insert('expenses', expense.toMap());
      await enqueueSync(txn, entityType: 'expense', entityId: expense.id, operation: 'create', payload: expense.toMap());
    });
  }

  Future<List<Expense>> getToday() async {
    final db = await _appDatabase.database;
    final startOfDay = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
    final rows = await db.query('expenses', where: 'created_at >= ?', whereArgs: [startOfDay.toIso8601String()], orderBy: 'created_at DESC');
    return rows.map(Expense.fromMap).toList();
  }

  Future<List<Expense>> getAll() async {
    final db = await _appDatabase.database;
    final rows = await db.query('expenses', orderBy: 'created_at DESC');
    return rows.map(Expense.fromMap).toList();
  }
}
