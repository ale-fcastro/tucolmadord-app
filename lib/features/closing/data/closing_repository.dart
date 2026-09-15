import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../core/auth/data/auth_exceptions.dart';
import '../../../core/auth/data/auth_session.dart';
import '../../../core/config/api_config.dart';
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
  final AuthSessionStore _session;
  final http.Client _client;

  static const _timeout = Duration(seconds: 20);

  ClosingRepository(this._appDatabase, this._session, {http.Client? client})
    : _client = client ?? http.Client();

  Future<DaySummary> getTodaySummary() async {
    final db = await _appDatabase.database;
    final startOfDay = DateTime.now()
        .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0)
        .toIso8601String();

    final salesRows = await db.query(
      'sales',
      where: 'created_at >= ?',
      whereArgs: [startOfDay],
    );
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

    final profitRows = await db.rawQuery(
      '''
      SELECT si.line_total AS line_total, si.quantity AS quantity, p.cost AS cost
      FROM sale_items si
      JOIN sales s ON si.sale_id = s.id
      LEFT JOIN products p ON si.product_id = p.id
      WHERE s.created_at >= ?
    ''',
      [startOfDay],
    );
    double profit = 0;
    for (final row in profitRows) {
      final lineTotal = (row['line_total'] as num).toDouble();
      final quantity = (row['quantity'] as num).toDouble();
      final cost = (row['cost'] as num?)?.toDouble();
      profit += lineTotal - (cost != null ? cost * quantity : 0);
    }

    final expenseRows = await db.query(
      'expenses',
      where: 'created_at >= ?',
      whereArgs: [startOfDay],
    );
    final expensesTotal = expenseRows.fold<double>(
      0,
      (sum, row) => sum + (row['amount'] as num).toDouble(),
    );

    final closedRows = await db.query(
      'cash_closings',
      where: 'date = ?',
      whereArgs: [_todayKey()],
    );

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

  /// Pide al backend que envíe por correo el reporte de cierre del día al
  /// dueño autenticado. El backend recalcula el resumen a partir de lo ya
  /// sincronizado — no se manda el `DaySummary` local — así que solo tiene
  /// sentido después de que las ventas del día hayan sincronizado.
  Future<void> sendReportEmail() async {
    final session = await _session.load();
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/reports/closing/email'),
          headers: {
            'Content-Type': 'application/json',
            if (session != null) 'Authorization': 'Bearer ${session.token}',
          },
          body: jsonEncode({'date': _todayKey()}),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) return;

    final body = _decode(response);
    throw ApiException(
      _message(body) ??
          'No se pudo enviar el reporte (${response.statusCode}).',
    );
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) return const {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return const {};
    } catch (_) {
      return const {};
    }
  }

  String? _message(Map<String, dynamic> body) {
    final message = body['message'];
    return (message is String && message.isNotEmpty) ? message : null;
  }
}
