/// Perfil del negocio — nombre, RNC/cédula, contacto y logo — usado para
/// personalizar la factura con la marca del colmado en vez de la de la app.
/// Espeja `CurrentBusinessResponse` de `GET/PUT /businesses/current`.
class BusinessProfile {
  const BusinessProfile({
    required this.id,
    required this.name,
    this.rnc,
    this.address,
    this.phone,
    this.logoBase64,
    required this.role,
  });

  final String id;
  final String name;
  final String? rnc;
  final String? address;
  final String? phone;

  /// Imagen del logo codificada en base64 (JPEG o PNG), o null si el
  /// negocio no cargó uno todavía.
  final String? logoBase64;
  final String role;

  bool get isOwner => role == 'Owner';

  factory BusinessProfile.fromJson(Map<String, dynamic> json) => BusinessProfile(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        rnc: json['rnc']?.toString(),
        address: json['address']?.toString(),
        phone: json['phone']?.toString(),
        logoBase64: json['logoBase64']?.toString(),
        role: json['role']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rnc': rnc,
        'address': address,
        'phone': phone,
        'logoBase64': logoBase64,
        'role': role,
      };
}
