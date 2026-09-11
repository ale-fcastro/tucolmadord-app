enum PaymentMethod { efectivo, transferencia, fiado }

String paymentMethodLabel(PaymentMethod m) => switch (m) {
      PaymentMethod.efectivo => 'Efectivo',
      PaymentMethod.transferencia => 'Transferencia',
      PaymentMethod.fiado => 'Fiado',
    };

class SaleItem {
  final String id;
  final String saleId;
  final String? productId;
  final String productName;
  final double quantity;
  final double? unitPrice;
  final double lineTotal;

  const SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'sale_id': saleId,
        'product_id': productId,
        'product_name': productName,
        'quantity': quantity,
        'unit_price': unitPrice,
        'line_total': lineTotal,
      };

  factory SaleItem.fromMap(Map<String, dynamic> map) => SaleItem(
        id: map['id'] as String,
        saleId: map['sale_id'] as String,
        productId: map['product_id'] as String?,
        productName: map['product_name'] as String,
        quantity: (map['quantity'] as num).toDouble(),
        unitPrice: (map['unit_price'] as num?)?.toDouble(),
        lineTotal: (map['line_total'] as num).toDouble(),
      );
}

class Sale {
  final String id;
  final double total;
  final PaymentMethod paymentMethod;
  final String? customerId;
  final double? receivedAmount;
  final double? changeAmount;
  final DateTime createdAt;
  final List<SaleItem> items;

  const Sale({
    required this.id,
    required this.total,
    required this.paymentMethod,
    this.customerId,
    this.receivedAmount,
    this.changeAmount,
    required this.createdAt,
    this.items = const [],
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'total': total,
        'payment_method': paymentMethod.name,
        'customer_id': customerId,
        'received_amount': receivedAmount,
        'change_amount': changeAmount,
        'created_at': createdAt.toIso8601String(),
      };

  factory Sale.fromMap(Map<String, dynamic> map) => Sale(
        id: map['id'] as String,
        total: (map['total'] as num).toDouble(),
        paymentMethod: PaymentMethod.values.firstWhere((m) => m.name == map['payment_method']),
        customerId: map['customer_id'] as String?,
        receivedAmount: (map['received_amount'] as num?)?.toDouble(),
        changeAmount: (map['change_amount'] as num?)?.toDouble(),
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
