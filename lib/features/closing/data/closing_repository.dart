import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/sync_queue.dart';
import '../domain/entities/day_summary.dart';

const _uuid = Uuid();

String _todayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

class ClosingRepository {
  final AppDatabase _appDatabase;

  ClosingRepository(this._appDatabase);

  Future<DaySummary> getTodaySummary() async {
    final db = await _appDatabase.database;
    final startOfDay = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0).toIso8601String();

    final salesRows = await db.query('sales', where: 'created_at >= ?', whereArgs: [startOfDay]);
    double cash = 0, transfer = 0, fiado = 0, total = 0;
    for (final row in salesRows) {
      final amount = (row['total'] as num).toDouble();
      total += amount;
      switch (row['payment_method']) {
        case 'efectivo':
          cash += amount;
        case 'transferencia':
          transfer += amount;
        case 'fiado':
          fiado += amount;
      }
    }

    final profitRows = await db.rawQuery('''
      SELECT si.line_total AS line_total, si.quantity AS quantity, p.cost AS cost
      FROM sale_items si
      JOIN sales s ON si.sale_id = s.id
      LEFT JOIN products p ON si.product_id = p.id
      WHERE s.created_at >= ?
    ''', [startOfDay]);
    double profit = 0;
    for (final row in profitRows) {
      final lineTotal = (row['line_total'] as num).toDouble();
      final quantity = (row['quantity'] as num).toDouble();
      final cost = (row['cost'] as num?)?.toDouble();
      profit += lineTotal - (cost != null ? cost * quantity : 0);
    }

    final expenseRows = await db.query('expenses', where: 'created_at >= ?', whereArgs: [startOfDay]);
    final expensesTotal = expenseRows.fold<double>(0, (sum, row) => sum + (row['amount'] as num).toDouble());

    final closedRows = await db.query('cash_closings', where: 'date = ?', whereArgs: [_todayKey()]);

    return DaySummary(
      totalSales: total,
      salesCount: salesRows.length,
      cashTotal: cash,
      transferTotal: transfer,
      fiadoTotal: fiado,
      expensesTotal: expensesTotal,
      estimatedProfit: profit - expensesTotal,
      closed: closedRows.isNotEmpty,
    );
  }

  Future<void> closeDay(DaySummary summary) async {
    final db = await _appDatabase.database;
    final closing = {
      'id': _uuid.v4(),
      'date': _todayKey(),
      'total_sales': summary.totalSales,
      'sales_count': summary.salesCount,
      'cash_total': summary.cashTotal,
      'transfer_total': summary.transferTotal,
      'fiado_total': summary.fiadoTotal,
      'expenses_total': summary.expensesTotal,
      'estimated_profit': summary.estimatedProfit,
      'closed_at': DateTime.now().toIso8601String(),
    };
    await db.transaction((txn) async {
      await txn.insert('cash_closings', closing);
      await enqueueSync(
        txn,
        entityType: 'cash_closing',
        entityId: closing['id'] as String,
        operation: 'create',
        payload: closing,
      );
    });
  }
}
