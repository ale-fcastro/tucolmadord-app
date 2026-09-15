import '../../data/business_models.dart';

class BusinessState {
  const BusinessState({this.loading = true, this.saving = false, this.profile, this.error});

  final bool loading;
  final bool saving;
  final BusinessProfile? profile;
  final String? error;

  BusinessState copyWith({bool? loading, bool? saving, BusinessProfile? profile, String? error}) => BusinessState(
        loading: loading ?? this.loading,
        saving: saving ?? this.saving,
        profile: profile ?? this.profile,
        error: error,
      );
}
