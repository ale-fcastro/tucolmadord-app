import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/customers/customers_repository.dart';
import '../../../../core/customers/entities/customer.dart';

class FiadoDetailState {
  final bool loading;
  final Customer? customer;
  final List<FiadoMovement> movements;

  const FiadoDetailState({
    this.loading = true,
    this.customer,
    this.movements = const [],
  });

  FiadoDetailState copyWith({
    bool? loading,
    Customer? customer,
    List<FiadoMovement>? movements,
  }) => FiadoDetailState(
    loading: loading ?? this.loading,
    customer: customer ?? this.customer,
    movements: movements ?? this.movements,
  );
}

class FiadoDetailCubit extends Cubit<FiadoDetailState> {
  final CustomersRepository _repository;
  final String customerId;

  FiadoDetailCubit(this._repository, this.customerId)
    : super(const FiadoDetailState()) {
    load();
  }

  Future<void> load() async {
    final customer = await _repository.getById(customerId);
    final movements = await _repository.getMovements(customerId);
    emit(
      state.copyWith(loading: false, customer: customer, movements: movements),
    );
  }

  Future<void> registerPayment({
    required double amount,
    required String paymentMethod,
  }) async {
    await _repository.registerPayment(
      customerId: customerId,
      amount: amount,
      paymentMethod: paymentMethod,
    );
    await load();
  }
}
