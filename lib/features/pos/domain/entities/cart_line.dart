import '../../../../core/products/entities/product.dart';

/// Línea del carrito en memoria — solo existe mientras se arma la venta.
/// No se persiste hasta que se confirma el cobro (ver SalesRepository.checkout).
class CartLine {
  final String id;
  final String? productId;
  final String name;
  final SellMode mode;
  final double quantity;
  final double? unitPrice;
  final double lineTotal;

  const CartLine({
    required this.id,
    required this.productId,
    required this.name,
    required this.mode,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  bool get isUnit => mode == SellMode.unit;

  CartLine copyWith({double? quantity, double? lineTotal}) => CartLine(
        id: id,
        productId: productId,
        name: name,
        mode: mode,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice,
        lineTotal: lineTotal ?? this.lineTotal,
      );
}
