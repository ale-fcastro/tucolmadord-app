import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/data/auth_exceptions.dart';
import '../../data/business_profile_store.dart';
import 'business_state.dart';

class BusinessCubit extends Cubit<BusinessState> {
  BusinessCubit(this._store) : super(const BusinessState()) {
    load();
  }

  final BusinessProfileStore _store;

  static const _connectionErrorMessage = 'No se pudo conectar con el servidor. Intenta de nuevo.';

  Future<void> load() async {
    emit(state.copyWith(loading: true, profile: _store.cached));
    final profile = await _store.load();
    emit(state.copyWith(loading: false, profile: profile));
  }

  Future<void> save({
    required String name,
    String? rnc,
    String? address,
    String? phone,
    String? logoBase64,
    bool removeLogo = false,
  }) async {
    emit(state.copyWith(saving: true, error: null));
    try {
      final updated = await _store.repository.update(
        name: name,
        rnc: rnc,
        address: address,
        phone: phone,
        logoBase64: logoBase64,
        removeLogo: removeLogo,
      );
      await _store.save(updated);
      emit(state.copyWith(saving: false, profile: updated));
    } on ApiException catch (e) {
      emit(state.copyWith(saving: false, error: e.message));
    } catch (_) {
      emit(state.copyWith(saving: false, error: _connectionErrorMessage));
    }
  }
}
