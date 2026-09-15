import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/customers/customers_repository.dart';
import '../../../../core/customers/entities/customer.dart';

class FiadosState {
  final bool loading;
  final List<Customer> customers;
  final String search;

  const FiadosState({
    this.loading = true,
    this.customers = const [],
    this.search = '',
  });

  double get totalPending =>
      customers.fold<double>(0, (sum, c) => sum + c.balance);

  List<Customer> get visible {
    final q = search.toLowerCase();
    final filtered = search.isEmpty
        ? customers
        : customers.where((c) => c.name.toLowerCase().contains(q));
    // Los que más deben aparecen primero; los saldados quedan al final, discretos.
    return filtered.toList()..sort((a, b) => b.balance.compareTo(a.balance));
  }

  FiadosState copyWith({
    bool? loading,
    List<Customer>? customers,
    String? search,
  }) => FiadosState(
    loading: loading ?? this.loading,
    customers: customers ?? this.customers,
    search: search ?? this.search,
  );
}

class FiadosCubit extends Cubit<FiadosState> {
  final CustomersRepository _repository;

  FiadosCubit(this._repository) : super(const FiadosState()) {
    load();
  }

  Future<void> load() async {
    final customers = await _repository.getAll();
    emit(state.copyWith(loading: false, customers: customers));
  }

  void setSearch(String value) => emit(state.copyWith(search: value));

  Future<void> addCustomer(String name) async {
    await _repository.addCustomer(name);
    await load();
  }
}
