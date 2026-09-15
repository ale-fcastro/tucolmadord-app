import 'package:google_sign_in/google_sign_in.dart';

import '../../config/google_auth_config.dart';

/// Envuelve `package:google_sign_in`: inicializa el SDK una sola vez con el
/// Web Client ID (el mismo que el backend valida como audience del ID
/// token) y expone el flujo de autenticación.
///
/// En Android/iOS/desktop, `signIn()` abre el selector de cuentas nativo. En
/// Web el SDK (Google Identity Services) no permite disparar el flujo desde
/// UI propia — hay que mostrar su botón oficial (`GoogleSignInButton`) y
/// escuchar [idTokenEvents] para saber cuándo el usuario terminó.
class GoogleAuthService {
  Future<void>? _initialization;

  /// Sin Web Client ID configurado, Google Sign-In no puede funcionar en
  /// ninguna plataforma — ver [GoogleAuthConfig].
  bool get isConfigured => GoogleAuthConfig.webClientId.isNotEmpty;

  Future<void> ensureInitialized() {
    return _initialization ??= GoogleSignIn.instance.initialize(
      clientId: GoogleAuthConfig.webClientId,
      serverClientId: GoogleAuthConfig.webClientId,
    );
  }

  /// true si la plataforma soporta `authenticate()` directo (Android/iOS/
  /// desktop). En Web es false — hay que usar el botón oficial en su lugar.
  /// Solo válido después de que [ensureInitialized] termine.
  bool get supportsAuthenticate => GoogleSignIn.instance.supportsAuthenticate();

  /// ID tokens de logins completados a través del botón oficial de Google
  /// en Web (el widget de `renderButton` dispara el flujo por su cuenta, no
  /// hay nada que esperar como en [signIn]).
  Stream<String> get idTokenEvents => GoogleSignIn.instance.authenticationEvents
      .map((event) {
        if (event is! GoogleSignInAuthenticationEventSignIn) return null;
        return event.user.authentication.idToken;
      })
      .where((idToken) => idToken != null)
      .cast<String>();

  /// Abre el selector de cuentas de Google y devuelve el ID token para
  /// mandar a `POST /auth/google`. Devuelve null si el usuario cancela.
  Future<String?> signIn() async {
    await ensureInitialized();
    try {
      final account = await GoogleSignIn.instance.authenticate();
      return account.authentication.idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }
}
