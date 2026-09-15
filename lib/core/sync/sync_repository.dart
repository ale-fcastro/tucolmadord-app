import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/data/auth_exceptions.dart';
import '../auth/data/auth_session.dart';
import '../config/api_config.dart';

/// Envuelve `POST /sync/push`, autenticado con el token de la sesión
/// guardada — igual que `BusinessRepository`. No conoce `sync_queue`; solo
/// manda lo que le pasan y devuelve, en el mismo orden, qué operaciones
/// aceptó el servidor.
class SyncRepository {
  SyncRepository(this._session, {http.Client? client})
    : _client = client ?? http.Client();

  final AuthSessionStore _session;
  final http.Client _client;

  static const _timeout = Duration(seconds: 30);

  Future<List<bool>> push(List<Map<String, dynamic>> operations) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/sync/push'),
          headers: await _authHeaders(),
          body: jsonEncode({'operations': operations}),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw ApiException('No se pudo sincronizar (${response.statusCode}).');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List? ?? const [];
    return results
        .map((e) => (e as Map<String, dynamic>)['accepted'] == true)
        .toList();
  }

  Future<Map<String, String>> _authHeaders() async {
    final session = await _session.load();
    return {
      'Content-Type': 'application/json',
      if (session != null) 'Authorization': 'Bearer ${session.token}',
    };
  }
}
