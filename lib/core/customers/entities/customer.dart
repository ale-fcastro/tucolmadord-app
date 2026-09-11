class Customer {
  final String id;
  final String name;
  final double balance;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.name,
    required this.balance,
    required this.createdAt,
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'balance': balance,
        'created_at': createdAt.toIso8601String(),
      };

  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
        id: map['id'] as String,
        name: map['name'] as String,
        balance: (map['balance'] as num).toDouble(),
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

enum FiadoMovementType { compra, pago }

class FiadoMovement {
  final String id;
  final String customerId;
  final FiadoMovementType type;
  final double amount;
  final String? note;
  final String? paymentMethod;
  final String? saleId;
  final DateTime createdAt;

  const FiadoMovement({
    required this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    this.note,
    this.paymentMethod,
    this.saleId,
    required this.createdAt,
  });

  factory FiadoMovement.fromMap(Map<String, dynamic> map) => FiadoMovement(
        id: map['id'] as String,
        customerId: map['customer_id'] as String,
        type: FiadoMovementType.values.firstWhere((t) => t.name == map['type']),
        amount: (map['amount'] as num).toDouble(),
        note: map['note'] as String?,
        paymentMethod: map['payment_method'] as String?,
        saleId: map['sale_id'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
