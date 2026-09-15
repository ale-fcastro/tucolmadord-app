import 'package:flutter/foundation.dart' show kReleaseMode;

/// Configuración de la API del backend (tucolmadord-api).
class ApiConfig {
  ApiConfig._();

  static const String _override = String.fromEnvironment('API_BASE_URL');

  /// Base URL del backend.
  ///
  /// - Si se pasa `--dart-define=API_BASE_URL=...` al build/run, esa URL
  ///   siempre gana (útil para un dispositivo físico en la misma red que un
  ///   backend local: `http://192.168.1.10:5000`).
  /// - En release (el APK que corre en un teléfono/tablet real, sin debugger
  ///   conectado) cae a la API de producción `api.tucolmadord.com`.
  /// - En debug cae al alias `10.0.2.2`, que solo resuelve dentro del
  ///   emulador de Android — por eso un release instalado en un dispositivo
  ///   físico sin este fallback mostraba "error al conectar con el
  ///   servidor": intentaba llegar a un host que no existe fuera del
  ///   emulador.
  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    return kReleaseMode
        ? 'https://api.tucolmadord.com'
        : 'http://10.0.2.2:5000';
  }
}
