/// Respuesta de `POST /auth/register`.
class RegisterResult {
  const RegisterResult({
    required this.userId,
    required this.email,
    required this.emailConfirmed,
  });

  final String userId;
  final String email;
  final bool emailConfirmed;
}

/// Sesión autenticada — misma forma que devuelven `/auth/verify-email` y
/// `/auth/login` en éxito, y lo que se persiste en almacenamiento seguro
/// entre reinicios de la app.
class AuthSessionData {
  const AuthSessionData({
    required this.token,
    required this.expiresAtUtc,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.businessId,
    required this.businessName,
  });

  final String token;
  final DateTime expiresAtUtc;
  final String userId;
  final String email;
  final String fullName;
  final String businessId;
  final String businessName;

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAtUtc);

  factory AuthSessionData.fromJson(Map<String, dynamic> json) {
    return AuthSessionData(
      token: json['token']?.toString() ?? '',
      expiresAtUtc:
          DateTime.tryParse(json['expiresAtUtc']?.toString() ?? '')?.toUtc() ??
          DateTime.now().toUtc().add(const Duration(hours: 1)),
      userId: json['userId']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      businessId: json['businessId']?.toString() ?? '',
      businessName: json['businessName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'expiresAtUtc': expiresAtUtc.toIso8601String(),
    'userId': userId,
    'email': email,
    'fullName': fullName,
    'businessId': businessId,
    'businessName': businessName,
  };
}

/// Ticket de corta duración que devuelve `POST /auth/google` (202) cuando el
/// correo de Google no tiene cuenta todavía. `CompleteGoogleRegistrationScreen`
/// lo reenvía junto con el nombre del negocio y el teléfono para crear la
/// cuenta — expira a los 10 minutos.
class GooglePendingRegistration {
  const GooglePendingRegistration({
    required this.registrationToken,
    required this.email,
    required this.fullName,
  });

  final String registrationToken;
  final String email;
  final String fullName;
}

/// Resultado de `POST /auth/google`: o bien el correo ya tenía cuenta y
/// [session] trae una sesión válida, o es nuevo y [pendingRegistration] trae
/// el ticket para completar el registro. Nunca vienen los dos a la vez.
class GoogleAuthResult {
  const GoogleAuthResult.session(this.session) : pendingRegistration = null;

  const GoogleAuthResult.pendingRegistration(this.pendingRegistration)
    : session = null;

  final AuthSessionData? session;
  final GooglePendingRegistration? pendingRegistration;
}
