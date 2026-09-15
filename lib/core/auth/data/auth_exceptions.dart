/// Excepción base para errores de la API de autenticación — `message` ya
/// viene listo para mostrarle al usuario (en español, tal como lo manda el
/// backend o un mensaje genérico si la respuesta no trae uno).
class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 409 en `/auth/register` — ya existe una cuenta con ese correo.
class DuplicateEmailException extends ApiException {
  DuplicateEmailException(super.message);
}

/// 401 en `/auth/login` — credenciales incorrectas (o body vacío).
class InvalidCredentialsException extends ApiException {
  InvalidCredentialsException([super.message = 'Correo o contraseña incorrectos.']);
}

/// 403 `EMAIL_NOT_CONFIRMED` en `/auth/login` — credenciales válidas pero el
/// correo todavía no fue confirmado. La UI debe redirigir a la pantalla de
/// verificación con este correo precargado.
class EmailNotConfirmedException extends ApiException {
  EmailNotConfirmedException({required this.email, required String message}) : super(message);

  final String email;
}

/// 400 con `ValidationProblemDetails` (`{ errors: { Campo: ["mensaje"] } }`)
/// en `/auth/register`. `errors` conserva las llaves tal como las manda
/// ASP.NET (PascalCase) — la UI hace el match case-insensitive.
class ValidationException extends ApiException {
  ValidationException(this.errors) : super(_firstMessage(errors));

  final Map<String, List<String>> errors;

  static String _firstMessage(Map<String, List<String>> errors) {
    for (final messages in errors.values) {
      if (messages.isNotEmpty) return messages.first;
    }
    return 'Revisa los datos ingresados.';
  }
}
