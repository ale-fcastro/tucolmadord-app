import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_models.dart';

/// Persiste la sesión (token + datos de usuario/negocio) en almacenamiento
/// seguro del dispositivo, para no pedir login en cada apertura de la app.
class AuthSessionStore {
  AuthSessionStore({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _key = 'tucolmadord_auth_session';

  Future<AuthSessionData?> load() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AuthSessionData.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(AuthSessionData session) {
    return _storage.write(key: _key, value: jsonEncode(session.toJson()));
  }

  Future<void> clear() {
    return _storage.delete(key: _key);
  }
}
