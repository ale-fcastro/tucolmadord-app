import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/expenses_repository.dart';
import '../../domain/entities/expense.dart';

class ExpensesState {
  final bool loading;
  final List<Expense> today;

  const ExpensesState({this.loading = true, this.today = const []});

  double get todayTotal => today.fold<double>(0, (sum, e) => sum + e.amount);

  ExpensesState copyWith({bool? loading, List<Expense>? today}) =>
      ExpensesState(loading: loading ?? this.loading, today: today ?? this.today);
}

class ExpensesCubit extends Cubit<ExpensesState> {
  final ExpensesRepository _repository;

  ExpensesCubit(this._repository) : super(const ExpensesState()) {
    load();
  }

  Future<void> load() async {
    try {
      final today = await _repository.getToday();
      emit(state.copyWith(loading: false, today: today));
    } catch (_) {
      emit(state.copyWith(loading: false));
    }
  }

  /// Puede lanzar si el repositorio falla; el llamador (la pantalla) debe
  /// capturar el error y mostrar feedback al usuario.
  Future<void> addExpense({required double amount, required String concept, required String category}) async {
    await _repository.add(amount: amount, concept: concept, category: category);
    await load();
  }
}
