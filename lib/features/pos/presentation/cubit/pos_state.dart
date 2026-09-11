import '../../../../core/customers/entities/customer.dart';
import '../../../../core/products/entities/product.dart';
import '../../domain/entities/cart_line.dart';
import '../../domain/entities/sale.dart';

class PosState {
  final bool loading;
  final List<Product> products;
  final List<Customer> customers;
  final String search;
  final String category;
  final List<CartLine> cart;
  final PaymentMethod paymentMethod;
  final double receivedAmount;
  final String? selectedCustomerId;
  final Sale? lastSale;

  const PosState({
    this.loading = true,
    this.products = const [],
    this.customers = const [],
    this.search = '',
    this.category = 'Frecuentes',
    this.cart = const [],
    this.paymentMethod = PaymentMethod.efectivo,
    this.receivedAmount = 0,
    this.selectedCustomerId,
    this.lastSale,
  });

  double get cartTotal => cart.fold<double>(0, (sum, l) => sum + l.lineTotal);
  int get cartCount => cart.fold<int>(0, (sum, l) => sum + (l.isUnit ? l.quantity.round() : 1));
  bool get cartHasItems => cart.isNotEmpty;
  double get changeAmount => (receivedAmount - cartTotal).clamp(0, double.infinity);

  List<Product> get visibleProducts {
    var list = products;
    if (search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    } else if (category == 'Frecuentes') {
      list = list.where((p) => p.isFrequent).toList();
    } else if (category != 'Todos') {
      list = list.where((p) => p.category == category).toList();
    }
    return list;
  }

  bool get canConfirmPayment {
    if (cart.isEmpty) return false;
    switch (paymentMethod) {
      case PaymentMethod.efectivo:
        return receivedAmount >= cartTotal;
      case PaymentMethod.transferencia:
        return true;
      case PaymentMethod.fiado:
        return selectedCustomerId != null;
    }
  }

  PosState copyWith({
    bool? loading,
    List<Product>? products,
    List<Customer>? customers,
    String? search,
    String? category,
    List<CartLine>? cart,
    PaymentMethod? paymentMethod,
    double? receivedAmount,
    String? selectedCustomerId,
    bool clearSelectedCustomerId = false,
    Sale? lastSale,
  }) {
    return PosState(
      loading: loading ?? this.loading,
      products: products ?? this.products,
      customers: customers ?? this.customers,
      search: search ?? this.search,
      category: category ?? this.category,
      cart: cart ?? this.cart,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      selectedCustomerId: clearSelectedCustomerId ? null : (selectedCustomerId ?? this.selectedCustomerId),
      lastSale: lastSale ?? this.lastSale,
    );
  }
}
