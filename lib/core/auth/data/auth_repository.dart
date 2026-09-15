import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import 'auth_exceptions.dart';
import 'auth_models.dart';

/// Envuelve los 4 endpoints de `/auth` del backend. No guarda estado ni
/// toca almacenamiento — eso lo hace `AuthSessionStore`. Cada método parsea
/// la respuesta según el contrato documentado o lanza una `ApiException`
/// (o subtipo) con el mensaje que debe verse en la UI.
class AuthRepository {
  AuthRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _timeout = Duration(seconds: 20);

  Future<RegisterResult> register({
    required String businessName,
    required String ownerFullName,
    required String email,
    required String password,
  }) async {
    final response = await _postJson('/auth/register', {
      'businessName': businessName,
      'ownerFullName': ownerFullName,
      'email': email,
      'password': password,
    });
    final body = _decode(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return RegisterResult(
        userId: body['userId']?.toString() ?? '',
        email: body['email']?.toString() ?? email,
        emailConfirmed: body['emailConfirmed'] == true,
      );
    }
    if (response.statusCode == 409) {
      throw DuplicateEmailException(
        _message(body) ?? 'Ya existe una cuenta con ese correo.',
      );
    }
    if (response.statusCode == 400) {
      final errors = body['errors'];
      if (errors is Map) {
        throw ValidationException(_parseFieldErrors(errors));
      }
      throw ApiException(_message(body) ?? 'Revisa los datos ingresados.');
    }
    throw ApiException(
      _message(body) ??
          'No se pudo completar el registro (${response.statusCode}).',
    );
  }

  Future<AuthSessionData> verifyEmail({
    required String email,
    required String code,
  }) async {
    final response = await _postJson('/auth/verify-email', {
      'email': email,
      'code': code,
    });
    final body = _decode(response);

    if (response.statusCode == 200) return AuthSessionData.fromJson(body);
    throw ApiException(_message(body) ?? 'Código inválido o expirado.');
  }

  Future<String> resendVerification({required String email}) async {
    final response = await _postJson('/auth/resend-verification', {
      'email': email,
    });
    final body = _decode(response);

    if (response.statusCode == 200) {
      return _message(body) ?? 'Código reenviado. Revisa tu correo.';
    }
    throw ApiException(
      _message(body) ??
          'No se pudo reenviar el código. Intenta de nuevo en un momento.',
    );
  }

  Future<AuthSessionData> login({
    required String email,
    required String password,
  }) async {
    final response = await _postJson('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      return AuthSessionData.fromJson(_decode(response));
    }
    if (response.statusCode == 403) {
      final body = _decode(response);
      final code = body['code']?.toString();
      final message =
          _message(body) ?? 'Debes verificar tu correo antes de continuar.';
      if (code == 'EMAIL_NOT_CONFIRMED') {
        throw EmailNotConfirmedException(email: email, message: message);
      }
      throw ApiException(message);
    }
    if (response.statusCode == 401) {
      throw InvalidCredentialsException();
    }
    throw ApiException('No se pudo iniciar sesión (${response.statusCode}).');
  }

  /// Valida el ID token de Google con el backend. 200 = el correo ya tenía
  /// cuenta y devuelve una sesión normal; 202 = correo nuevo, devuelve el
  /// ticket que hay que completar con `completeGoogleRegistration`.
  Future<GoogleAuthResult> googleAuth({required String idToken}) async {
    final response = await _postJson('/auth/google', {'idToken': idToken});

    if (response.statusCode == 200) {
      return GoogleAuthResult.session(
        AuthSessionData.fromJson(_decode(response)),
      );
    }
    if (response.statusCode == 202) {
      final body = _decode(response);
      return GoogleAuthResult.pendingRegistration(
        GooglePendingRegistration(
          registrationToken: body['registrationToken']?.toString() ?? '',
          email: body['email']?.toString() ?? '',
          fullName: body['fullName']?.toString() ?? '',
        ),
      );
    }
    if (response.statusCode == 403) {
      final body = _decode(response);
      throw ApiException(
        _message(body) ?? 'No se pudo iniciar sesión con Google.',
      );
    }
    if (response.statusCode == 401) {
      throw ApiException(
        'No se pudo iniciar sesión con Google. Intenta de nuevo.',
      );
    }
    throw ApiException(
      'No se pudo iniciar sesión con Google (${response.statusCode}).',
    );
  }

  /// Crea la cuenta + negocio para un correo de Google sin cuenta todavía,
  /// usando el ticket que devolvió `googleAuth`.
  Future<AuthSessionData> completeGoogleRegistration({
    required String registrationToken,
    required String businessName,
    required String phone,
  }) async {
    final response = await _postJson('/auth/google/register', {
      'registrationToken': registrationToken,
      'businessName': businessName,
      'phone': phone,
    });
    final body = _decode(response);

    if (response.statusCode == 200) return AuthSessionData.fromJson(body);
    if (response.statusCode == 403) {
      throw ApiException(
        _message(body) ?? 'No se pudo completar el registro con Google.',
      );
    }
    if (response.statusCode == 400) {
      final errors = body['errors'];
      if (errors is Map) {
        throw ValidationException(_parseFieldErrors(errors));
      }
      throw ApiException(_message(body) ?? 'Revisa los datos ingresados.');
    }
    throw ApiException(
      _message(body) ??
          'No se pudo completar el registro (${response.statusCode}).',
    );
  }

  Future<http.Response> _postJson(String path, Map<String, dynamic> body) {
    return _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(_timeout);
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

  Map<String, List<String>> _parseFieldErrors(Map errors) {
    return errors.map((key, value) {
      final messages = value is List
          ? value.map((e) => e.toString()).toList()
          : <String>[value.toString()];
      return MapEntry(key.toString(), messages);
    });
  }
}
