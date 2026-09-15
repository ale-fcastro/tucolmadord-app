import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/closing_repository.dart';
import '../../domain/entities/day_summary.dart';

/// Estado de la pantalla de cierre. Envuelve el [DaySummary] con banderas de
/// carga/cierre y un mensaje de error transitorio, para que la UI pueda
/// distinguir "todavía cargando" de "un día real sin ventas" y mostrar
/// errores sin dejar al dueño adivinando si el cierre se aplicó.
class ClosingState {
  final DaySummary summary;
  final bool isLoading;
  final bool isClosing;
  final bool isSendingEmail;
  final String? errorMessage;
  final String? successMessage;

  const ClosingState({
    required this.summary,
    this.isLoading = false,
    this.isClosing = false,
    this.isSendingEmail = false,
    this.errorMessage,
    this.successMessage,
  });

  static const initial = ClosingState(summary: DaySummary.empty, isLoading: true);

  ClosingState copyWith({
    DaySummary? summary,
    bool? isLoading,
    bool? isClosing,
    bool? isSendingEmail,
    String? errorMessage,
    String? successMessage,
  }) {
    return ClosingState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      isClosing: isClosing ?? this.isClosing,
      isSendingEmail: isSendingEmail ?? this.isSendingEmail,
      // No se heredan: cada emisión sin mensaje explícito limpia el anterior.
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class ClosingCubit extends Cubit<ClosingState> {
  final ClosingRepository _repository;

  ClosingCubit(this._repository) : super(ClosingState.initial) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final summary = await _repository.getTodaySummary();
      emit(state.copyWith(summary: summary, isLoading: false));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudo cargar el resumen del día.',
      ));
    }
  }

  Future<void> closeDay() async {
    emit(state.copyWith(isClosing: true));
    try {
      await _repository.closeDay(state.summary);
      final summary = await _repository.getTodaySummary();
      emit(state.copyWith(summary: summary, isClosing: false));
    } catch (_) {
      emit(state.copyWith(
        isClosing: false,
        errorMessage: 'No se pudo cerrar el día. Intenta de nuevo.',
      ));
    }
  }

  Future<void> sendReportEmail() async {
    emit(state.copyWith(isSendingEmail: true));
    try {
      await _repository.sendReportEmail();
      emit(state.copyWith(
        isSendingEmail: false,
        successMessage: 'Reporte enviado a tu correo.',
      ));
    } catch (_) {
      emit(state.copyWith(
        isSendingEmail: false,
        errorMessage: 'No se pudo enviar el reporte. Intenta de nuevo.',
      ));
    }
  }
}
