import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/customers/customers_repository.dart';
import '../../../../core/products/products_repository.dart';
import '../../../closing/data/closing_repository.dart';
import '../../../expenses/data/expenses_repository.dart';
import '../../../pos/data/sales_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final SalesRepository _salesRepository;
  final ExpensesRepository _expensesRepository;
  final ClosingRepository _closingRepository;
  final ProductsRepository _productsRepository;
  final CustomersRepository _customersRepository;

  HomeCubit(
    this._salesRepository,
    this._expensesRepository,
    this._closingRepository,
    this._productsRepository,
    this._customersRepository,
  ) : super(const HomeState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final sales = await _salesRepository.getToday();
      final expenses = await _expensesRepository.getToday();
      final payments = await _customersRepository.getTodayPayments();
      final summary = await _closingRepository.getTodaySummary();
      final products = await _productsRepository.getAll();
      final customers = await _customersRepository.getAll();

      final activity = <ActivityItem>[
        ...sales.map(
          (s) => ActivityItem(
            type: ActivityType.sale,
            title: 'Venta #${s.id.substring(0, 6)}',
            time: s.createdAt,
            amount: s.total,
          ),
        ),
        ...payments.map(
          (p) => ActivityItem(
            type: ActivityType.payment,
            title: 'Pago de fiado — ${p['customer_name']}',
            time: DateTime.parse(p['created_at'] as String),
            amount: (p['amount'] as num).toDouble(),
          ),
        ),
        ...expenses.map(
          (e) => ActivityItem(
            type: ActivityType.expense,
            title: 'Gasto — ${e.concept}',
            time: e.createdAt,
            amount: e.amount,
          ),
        ),
      ]..sort((a, b) => b.time.compareTo(a.time));

      final todayExpensesTotal = expenses.fold<double>(
        0,
        (sum, e) => sum + e.amount,
      );

      emit(
        state.copyWith(
          loading: false,
          hasLoadedOnce: true,
          error: null,
          todaySales: summary.totalSales,
          estimatedProfit: summary.estimatedProfit,
          fiadoPending: _customersRepository.totalPending(customers),
          todayExpenses: todayExpensesTotal,
          lowStockCount: products.where((p) => p.isLowStock).length,
          recentActivity: activity.take(3).toList(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'No se pudo cargar la información. Intenta de nuevo.',
        ),
      );
    }
  }
}
