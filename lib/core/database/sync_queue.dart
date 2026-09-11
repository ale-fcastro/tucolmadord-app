import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Encola un cambio local para sincronizar con el servidor más adelante.
/// Se debe llamar SIEMPRE dentro de la misma transacción que la operación
/// que originó el cambio — así nunca hay una venta/gasto/pago registrado
/// localmente que la cola "olvide".
Future<void> enqueueSync(
  Transaction txn, {
  required String entityType,
  required String entityId,
  required String operation,
  required Map<String, dynamic> payload,
}) async {
  await txn.insert('sync_queue', {
    'id': _uuid.v4(),
    'entity_type': entityType,
    'entity_id': entityId,
    'operation': operation,
    'payload_json': jsonEncode(payload),
    'status': 'pending',
    'retry_count': 0,
    'created_at': DateTime.now().toIso8601String(),
  });
}
