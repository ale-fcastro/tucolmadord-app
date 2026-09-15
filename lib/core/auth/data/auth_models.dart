/// Respuesta de `POST /auth/register`.
class RegisterResult {
  const RegisterResult({required this.userId, required this.email, required this.emailConfirmed});

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
      expiresAtUtc: DateTime.tryParse(json['expiresAtUtc']?.toString() ?? '')?.toUtc() ??
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
