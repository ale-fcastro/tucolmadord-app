import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/auth/data/auth_exceptions.dart';
import '../../../core/auth/data/auth_session.dart';
import '../../../core/config/api_config.dart';
import 'business_models.dart';

/// Envuelve `GET/PUT /businesses/current`. A diferencia de `AuthRepository`
/// (endpoints pre-login), estas llamadas van autenticadas con el token de la
/// sesión guardada.
class BusinessRepository {
  BusinessRepository(this._session, {http.Client? client}) : _client = client ?? http.Client();

  final AuthSessionStore _session;
  final http.Client _client;

  static const _timeout = Duration(seconds: 20);

  Future<BusinessProfile> getCurrent() async {
    final response = await _client
        .get(Uri.parse('${ApiConfig.baseUrl}/businesses/current'), headers: await _authHeaders())
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return BusinessProfile.fromJson(_decode(response));
    }
    throw ApiException('No se pudo cargar el perfil del negocio (${response.statusCode}).');
  }

  Future<BusinessProfile> update({
    required String name,
    String? rnc,
    String? address,
    String? phone,
    String? logoBase64,
    bool removeLogo = false,
  }) async {
    final response = await _client
        .put(
          Uri.parse('${ApiConfig.baseUrl}/businesses/current'),
          headers: await _authHeaders(),
          body: jsonEncode({
            'name': name,
            'rnc': rnc,
            'address': address,
            'phone': phone,
            'logoBase64': logoBase64,
            'removeLogo': removeLogo,
          }),
        )
        .timeout(_timeout);

    final body = _decode(response);
    if (response.statusCode == 200) {
      return BusinessProfile.fromJson(body);
    }
    if (response.statusCode == 403) {
      throw ApiException(_message(body) ?? 'Solo el dueño del negocio puede editar estos datos.');
    }
    if (response.statusCode == 400) {
      throw ApiException(_message(body) ?? 'Revisa los datos ingresados.');
    }
    throw ApiException(_message(body) ?? 'No se pudo guardar (${response.statusCode}).');
  }

  Future<Map<String, String>> _authHeaders() async {
    final session = await _session.load();
    return {
      'Content-Type': 'application/json',
      if (session != null) 'Authorization': 'Bearer ${session.token}',
    };
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
