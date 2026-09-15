import 'dart:async';
import 'dart:convert';

import '../database/app_database.dart';
import 'sync_repository.dart';

/// Empuja periódicamente lo acumulado en `sync_queue` hacia `/sync/push`
/// mientras la app está en primer plano. La sincronización es de ida
/// (mobile → API): el dashboard es quien lee de la API, así que este
/// scheduler nunca hace pull.
///
/// `start()`/`stop()` los maneja `AppShell` (única pantalla que se muestra
/// con sesión activa) para que no corra sin un usuario logueado.
class SyncScheduler {
  SyncScheduler(this._repository, this._database);

  final SyncRepository _repository;
  final AppDatabase _database;

  static const _interval = Duration(minutes: 3);
  static const _batchSize = 50;
  static const _maxRetries = 8;

  Timer? _timer;
  bool _running = false;

  void start() {
    if (_timer != null) return;
    _timer = Timer.periodic(_interval, (_) => _tick());
    _tick();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _tick() async {
    if (_running) return;
    _running = true;
    try {
      var hasMore = true;
      while (hasMore) {
        hasMore = await _pushBatch();
      }
    } catch (_) {
      // Best-effort: sin red o el server no responde, se reintenta en el
      // próximo tick. Las filas siguen 'pending' en sync_queue.
    } finally {
      _running = false;
    }
  }

  /// Empuja un lote de filas pendientes. Devuelve true si el lote vino
  /// lleno (puede haber más pendientes detrás).
  Future<bool> _pushBatch() async {
    final db = await _database.database;
    final rows = await db.query(
      'sync_queue',
      where: "status = 'pending'",
      orderBy: 'created_at ASC',
      limit: _batchSize,
    );
    if (rows.isEmpty) return false;

    final operations = rows
        .map((row) => {
              'entityType': row['entity_type'],
              'entityId': row['entity_id'],
              'operation': row['operation'],
              'payload': jsonDecode(row['payload_json'] as String),
            })
        .toList();

    final accepted = await _repository.push(operations);

    final batch = db.batch();
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final wasAccepted = i < accepted.length && accepted[i];
      if (wasAccepted) {
        batch.delete('sync_queue', where: 'id = ?', whereArgs: [row['id']]);
        continue;
      }
      final retryCount = (row['retry_count'] as int) + 1;
      batch.update(
        'sync_queue',
        {
          'retry_count': retryCount,
          'last_attempt_at': DateTime.now().toIso8601String(),
          // Después de varios rechazos seguidos (payload inválido, etc.) se
          // deja de reintentar esa fila puntual para no trabar el resto de
          // la cola con algo que nunca va a aceptar el servidor.
          'status': retryCount >= _maxRetries ? 'error' : 'pending',
        },
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
    await batch.commit(noResult: true);

    return rows.length == _batchSize;
  }
}
