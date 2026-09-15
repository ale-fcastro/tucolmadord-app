/// Configuración de la API del backend (tucolmadord-api).
class ApiConfig {
  ApiConfig._();

  /// Base URL del backend. Por defecto apunta al emulador de Android
  /// (`10.0.2.2` es el alias del `localhost` de la máquina anfitriona desde
  /// el emulador). Para simulador de iOS, dispositivo físico o un deploy
  /// real, sobreescribir en build/run con:
  ///
  /// ```
  /// flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5000
  /// ```
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );
}
