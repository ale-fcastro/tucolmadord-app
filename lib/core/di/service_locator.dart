import 'package:get_it/get_it.dart';

import '../auth/data/auth_repository.dart';
import '../auth/data/auth_session.dart';
import '../auth/presentation/cubit/auth_cubit.dart';
import '../../features/business/data/business_profile_store.dart';
import '../../features/business/data/business_repository.dart';
import '../../features/business/presentation/cubit/business_cubit.dart';
import '../../features/closing/data/closing_repository.dart';
import '../../features/closing/presentation/cubit/closing_cubit.dart';
import '../../features/expenses/data/expenses_repository.dart';
import '../../features/expenses/presentation/cubit/expenses_cubit.dart';
import '../../features/fiados/presentation/cubit/fiados_cubit.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/pos/data/sales_repository.dart';
import '../../features/pos/presentation/cubit/pos_cubit.dart';
import '../../features/products/presentation/cubit/products_cubit.dart';
import '../customers/customers_repository.dart';
import '../database/app_database.dart';
import '../products/products_repository.dart';
import '../sync/sync_repository.dart';
import '../sync/sync_scheduler.dart';

final sl = GetIt.instance;

/// Registra todos los servicios/datasources/repositorios/blocs de la app.
/// Se llama una sola vez en main(), antes de runApp().
///
/// Convención: cada feature registra los suyos en su propia función
/// `_registerXFeature()` — así esta función no crece sin límite a medida
/// que se agregan features nuevas. Un servicio usado por una sola feature
/// se registra en la función de esa feature, no acá arriba.
Future<void> configureDependencies() async {
  // Transversales (usados por 2+ features) van acá directo.
  sl.registerLazySingleton(() => AppDatabase());
  sl.registerLazySingleton(() => ProductsRepository(sl()));
  sl.registerLazySingleton(() => CustomersRepository(sl()));

  _registerAuthFeature();
  _registerBusinessFeature();
  _registerPosFeature();
  _registerProductsFeature();
  _registerFiadosFeature();
  _registerExpensesFeature();
  _registerClosingFeature();
  _registerHomeFeature();
  _registerSyncFeature();
}

void _registerAuthFeature() {
  sl.registerLazySingleton(() => AuthRepository());
  sl.registerLazySingleton(() => AuthSessionStore());
  sl.registerFactory(() => AuthCubit(sl(), sl()));
}

void _registerBusinessFeature() {
  sl.registerLazySingleton(() => BusinessRepository(sl()));
  sl.registerLazySingleton(() => BusinessProfileStore(sl()));
  sl.registerFactory(() => BusinessCubit(sl()));
}

void _registerPosFeature() {
  sl.registerLazySingleton(() => SalesRepository(sl(), sl(), sl()));
  sl.registerFactory(() => PosCubit(sl(), sl(), sl()));
}

void _registerProductsFeature() {
  sl.registerFactory(() => ProductsCubit(sl()));
}

void _registerFiadosFeature() {
  sl.registerFactory(() => FiadosCubit(sl()));
}

void _registerExpensesFeature() {
  sl.registerLazySingleton(() => ExpensesRepository(sl()));
  sl.registerFactory(() => ExpensesCubit(sl()));
}

void _registerClosingFeature() {
  sl.registerLazySingleton(() => ClosingRepository(sl(), sl()));
  sl.registerFactory(() => ClosingCubit(sl()));
}

void _registerHomeFeature() {
  sl.registerFactory(() => HomeCubit(sl(), sl(), sl(), sl(), sl()));
}

void _registerSyncFeature() {
  sl.registerLazySingleton(() => SyncRepository(sl()));
  sl.registerLazySingleton(() => SyncScheduler(sl(), sl()));
}
