import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'business_models.dart';
import 'business_repository.dart';

/// Cachea el perfil del negocio en almacenamiento seguro y en memoria, para
/// que pantallas como el recibo lo lean de forma síncrona (sin spinner) aun
/// si el dispositivo está offline. `load()` intenta refrescar desde la API
/// y, si falla, cae en lo último guardado — igual de "offline-first" que el
/// resto de la app.
class BusinessProfileStore {
  BusinessProfileStore(this._repository, {FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final BusinessRepository _repository;
  final FlutterSecureStorage _storage;

  static const _key = 'tucolmadord_business_profile';

  BusinessRepository get repository => _repository;

  BusinessProfile? _cached;

  /// Último perfil conocido, disponible sin esperar red ni storage.
  BusinessProfile? get cached => _cached;

  Future<BusinessProfile?> load() async {
    try {
      final fresh = await _repository.getCurrent();
      await _save(fresh);
      return fresh;
    } catch (_) {
      final stored = await _readStored();
      _cached = stored;
      return stored;
    }
  }

  Future<void> save(BusinessProfile profile) => _save(profile);

  Future<BusinessProfile?> _readStored() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return BusinessProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _save(BusinessProfile profile) async {
    _cached = profile;
    await _storage.write(key: _key, value: jsonEncode(profile.toJson()));
  }
}
