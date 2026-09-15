import '../../data/auth_models.dart';

sealed class AuthState {
  const AuthState();
}

/// Estado transitorio inicial — se está revisando si hay una sesión
/// guardada en almacenamiento seguro. El gate en main.dart muestra un
/// spinner mientras dure.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Sin sesión válida. `error` es un mensaje genérico (credenciales
/// incorrectas, correo duplicado, fallo de red...) para mostrar con
/// `AppNotification.error`. `fieldErrors` son errores de validación del
/// backend por campo (solo lo devuelve `/auth/register`) — las llaves vienen
/// tal como las manda ASP.NET (ej. "BusinessName"), el match es
/// case-insensitive.
class Unauthenticated extends AuthState {
  const Unauthenticated({this.error, this.fieldErrors});

  final String? error;
  final Map<String, List<String>>? fieldErrors;
}

/// Login o registro en curso — las pantallas usan esto para deshabilitar el
/// formulario y mostrar el spinner del botón.
class Authenticating extends AuthState {
  const Authenticating();
}

/// Falta confirmar el correo — ya sea recién registrado o porque el login
/// devolvió `EMAIL_NOT_CONFIRMED`. `email` se precarga en VerifyEmailScreen.
class NeedsVerification extends AuthState {
  const NeedsVerification({required this.email, this.isSubmitting = false, this.error, this.info});

  final String email;

  /// true mientras se envía el código a verificar (para el botón "Verificar").
  final bool isSubmitting;

  /// Mensaje de error de la última verificación o reenvío fallido.
  final String? error;

  /// Mensaje informativo (ej. "Código reenviado") tras un reenvío exitoso.
  final String? info;
}

/// Sesión válida — el gate muestra el AppShell normal de la app.
class Authenticated extends AuthState {
  const Authenticated(this.session);

  final AuthSessionData session;
}
