/// Configuración de Google Sign-In.
class GoogleAuthConfig {
  GoogleAuthConfig._();

  static const String _override = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );

  /// El Client ID no es secreto — viaja embebido en cualquier app que lo
  /// use, Android incluida — así que a diferencia de `ApiConfig.baseUrl` no
  /// hace falta un dart-define en cada build: cae a este valor por defecto,
  /// que es el mismo en Web/Android/backend (ver `GoogleAuth:ClientId` en
  /// appsettings.json). `--dart-define=GOOGLE_WEB_CLIENT_ID=...` lo pisa si
  /// alguna vez hace falta apuntar a otro proyecto de Google Cloud.
  static const String _default =
      '413885875838-ps0kuecej4nn9og1ec8itphd1g3bfp4u.apps.googleusercontent.com';

  /// Web Client ID de OAuth, creado en Google Cloud Console. Se usa como
  /// `serverClientId` en Android/iOS/desktop (así el ID token trae ese
  /// client como audience, que es justo lo que el backend valida) y como
  /// `clientId` en Web.
  static String get webClientId => _override.isNotEmpty ? _override : _default;
}
