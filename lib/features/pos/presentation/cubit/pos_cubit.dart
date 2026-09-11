import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/customers/customers_repository.dart';
import '../../../../core/products/entities/product.dart';
import '../../../../core/products/products_repository.dart';
import '../../data/sales_repository.dart';
import '../../domain/entities/cart_line.dart';
import '../../domain/entities/sale.dart';
import 'pos_state.dart';

const _uuid = Uuid();

class PosCubit extends Cubit<PosState> {
  final ProductsRepository _productsRepository;
  final CustomersRepository _customersRepository;
  final SalesRepository _salesRepository;

  PosCubit(this._productsRepository, this._customersRepository, this._salesRepository)
      : super(const PosState()) {
    _load();
  }

  Future<void> _load() async {
    final products = await _productsRepository.getAll();
    final customers = await _customersRepository.getAll();
    emit(state.copyWith(loading: false, products: products, customers: customers));
  }

  void setSearch(String value) => emit(state.copyWith(search: value));
  void setCategory(String value) => emit(state.copyWith(category: value, search: ''));

  void addUnitToCart(Product product) {
    final existing = state.cart.where((l) => l.productId == product.id && l.isUnit).firstOrNull;
    if (existing != null) {
      final newQty = existing.quantity + 1;
      final updated = state.cart
          .map((l) => l.id == existing.id
              ? l.copyWith(quantity: newQty, lineTotal: newQty * (product.price ?? 0))
              : l)
          .toList();
      emit(state.copyWith(cart: updated));
      return;
    }
    final line = CartLine(
      id: _uuid.v4(),
      productId: product.id,
      name: product.name,
      mode: SellMode.unit,
      quantity: 1,
      unitPrice: product.price,
      lineTotal: product.price ?? 0,
    );
    emit(state.copyWith(cart: [...state.cart, line]));
  }

  void addAmountToCart(Product product, double amount) {
    final line = CartLine(
      id: _uuid.v4(),
      productId: product.id,
      name: product.name,
      mode: SellMode.amount,
      quantity: 1,
      unitPrice: null,
      lineTotal: amount,
    );
    emit(state.copyWith(cart: [...state.cart, line]));
  }

  void addWeightToCart(Product product, double qty) {
    final total = qty * (product.price ?? 0);
    final line = CartLine(
      id: _uuid.v4(),
      productId: product.id,
      name: product.name,
      mode: SellMode.weight,
      quantity: qty,
      unitPrice: product.price,
      lineTotal: total,
    );
    emit(state.copyWith(cart: [...state.cart, line]));
  }

  void incrementLine(String lineId) {
    final updated = state.cart.map((l) {
      if (l.id != lineId) return l;
      final newQty = l.quantity + 1;
      return l.copyWith(quantity: newQty, lineTotal: newQty * (l.unitPrice ?? 0));
    }).toList();
    emit(state.copyWith(cart: updated));
  }

  void decrementLine(String lineId) {
    final line = state.cart.firstWhere((l) => l.id == lineId);
    if (line.quantity <= 1) {
      removeLine(lineId);
      return;
    }
    final newQty = line.quantity - 1;
    final updated = state.cart
        .map((l) => l.id == lineId ? l.copyWith(quantity: newQty, lineTotal: newQty * (l.unitPrice ?? 0)) : l)
        .toList();
    emit(state.copyWith(cart: updated));
  }

  void removeLine(String lineId) {
    emit(state.copyWith(cart: state.cart.where((l) => l.id != lineId).toList()));
  }

  void selectPaymentMethod(PaymentMethod method) =>
      emit(state.copyWith(paymentMethod: method, receivedAmount: 0, clearSelectedCustomerId: true));

  void setReceivedAmount(double amount) => emit(state.copyWith(receivedAmount: amount));

  void selectCustomer(String customerId) => emit(state.copyWith(selectedCustomerId: customerId));

  Future<void> confirmSale() async {
    final sale = await _salesRepository.checkout(
      cart: state.cart,
      paymentMethod: state.paymentMethod,
      customerId: state.paymentMethod == PaymentMethod.fiado ? state.selectedCustomerId : null,
      receivedAmount: state.paymentMethod == PaymentMethod.efectivo ? state.receivedAmount : null,
      changeAmount: state.paymentMethod == PaymentMethod.efectivo ? state.changeAmount : null,
    );
    final products = await _productsRepository.getAll();
    final customers = await _customersRepository.getAll();
    emit(PosState(loading: false, products: products, customers: customers, lastSale: sale));
  }

  void startNewSale() {
    emit(state.copyWith(cart: const [], receivedAmount: 0, clearSelectedCustomerId: true));
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
