import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/closing_repository.dart';
import '../../domain/entities/day_summary.dart';

class ClosingCubit extends Cubit<DaySummary> {
  final ClosingRepository _repository;

  ClosingCubit(this._repository) : super(DaySummary.empty) {
    load();
  }

  Future<void> load() async {
    emit(await _repository.getTodaySummary());
  }

  Future<void> closeDay() async {
    await _repository.closeDay(state);
    await load();
  }
}
