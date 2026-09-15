import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_exceptions.dart';
import '../../data/auth_repository.dart';
import '../../data/auth_session.dart';
import 'auth_state.dart';

/// Orquesta el flujo de autenticación completo: revisar sesión guardada al
/// arrancar, registro, login, verificación de correo, reenvío de código y
/// logout. Las pantallas reaccionan a los estados que emite — ninguna
/// navega manualmente en el camino feliz, es el gate en main.dart el que
/// decide qué mostrar según el estado actual.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository, this._session) : super(const AuthInitial());

  final AuthRepository _repository;
  final AuthSessionStore _session;

  static const _connectionErrorMessage = 'No se pudo conectar con el servidor. Intenta de nuevo.';

  /// Se llama una sola vez al arrancar la app. Si hay una sesión guardada y
  /// no está vencida, entra directo (Authenticated); si no, muestra login.
  Future<void> checkStoredSession() async {
    final stored = await _session.load();
    if (stored != null && !stored.isExpired) {
      emit(Authenticated(stored));
      return;
    }
    if (stored != null) await _session.clear();
    emit(const Unauthenticated());
  }

  Future<void> register({
    required String businessName,
    required String ownerFullName,
    required String email,
    required String password,
  }) async {
    emit(const Authenticating());
    try {
      final result = await _repository.register(
        businessName: businessName,
        ownerFullName: ownerFullName,
        email: email,
        password: password,
      );
      emit(NeedsVerification(email: result.email));
    } on ValidationException catch (e) {
      emit(Unauthenticated(fieldErrors: e.errors));
    } on ApiException catch (e) {
      emit(Unauthenticated(error: e.message));
    } catch (_) {
      emit(const Unauthenticated(error: _connectionErrorMessage));
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(const Authenticating());
    try {
      final session = await _repository.login(email: email, password: password);
      await _session.save(session);
      emit(Authenticated(session));
    } on EmailNotConfirmedException catch (e) {
      emit(NeedsVerification(email: e.email, info: e.message));
    } on ApiException catch (e) {
      emit(Unauthenticated(error: e.message));
    } catch (_) {
      emit(const Unauthenticated(error: _connectionErrorMessage));
    }
  }

  Future<void> verifyEmail({required String email, required String code}) async {
    emit(NeedsVerification(email: email, isSubmitting: true));
    try {
      final session = await _repository.verifyEmail(email: email, code: code);
      await _session.save(session);
      emit(Authenticated(session));
    } on ApiException catch (e) {
      emit(NeedsVerification(email: email, error: e.message));
    } catch (_) {
      emit(NeedsVerification(email: email, error: _connectionErrorMessage));
    }
  }

  Future<void> resendVerification(String email) async {
    try {
      final message = await _repository.resendVerification(email: email);
      emit(NeedsVerification(email: email, info: message));
    } on ApiException catch (e) {
      emit(NeedsVerification(email: email, error: e.message));
    } catch (_) {
      emit(NeedsVerification(email: email, error: _connectionErrorMessage));
    }
  }

  Future<void> logout() async {
    await _session.clear();
    emit(const Unauthenticated());
  }
}
