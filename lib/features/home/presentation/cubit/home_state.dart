import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';

enum ActivityType { sale, payment, expense }

class ActivityItem {
  final ActivityType type;
  final String title;
  final DateTime time;
  final double amount;

  const ActivityItem({required this.type, required this.title, required this.time, required this.amount});

  IconData get icon => switch (type) {
        ActivityType.sale => Icons.point_of_sale_outlined,
        ActivityType.payment => Icons.receipt_long_outlined,
        ActivityType.expense => Icons.receipt_long_outlined,
      };

  Color get color => switch (type) {
        ActivityType.sale => AppColors.success,
        ActivityType.payment => AppColors.primary,
        ActivityType.expense => AppColors.error,
      };

  Color get bgColor => switch (type) {
        ActivityType.sale => AppColors.successBg,
        ActivityType.payment => AppColors.infoBg,
        ActivityType.expense => AppColors.errorBg,
      };
}

/// Sentinel used by [HomeState.copyWith] so `error` can be explicitly reset
/// to null (a plain `error ?? this.error` would never allow clearing it).
const Object _unsetError = Object();

class HomeState {
  final bool loading;
  final double todaySales;
  final double estimatedProfit;
  final double fiadoPending;
  final double todayExpenses;
  final int lowStockCount;
  final List<ActivityItem> recentActivity;
  final String? error;

  /// True once a load() call has completed successfully at least once.
  /// Used to avoid blanking the screen (spinner or error state) on a
  /// background refresh when we already have data to show.
  final bool hasLoadedOnce;

  const HomeState({
    this.loading = true,
    this.todaySales = 0,
    this.estimatedProfit = 0,
    this.fiadoPending = 0,
    this.todayExpenses = 0,
    this.lowStockCount = 0,
    this.recentActivity = const [],
    this.error,
    this.hasLoadedOnce = false,
  });

  HomeState copyWith({
    bool? loading,
    double? todaySales,
    double? estimatedProfit,
    double? fiadoPending,
    double? todayExpenses,
    int? lowStockCount,
    List<ActivityItem>? recentActivity,
    Object? error = _unsetError,
    bool? hasLoadedOnce,
  }) {
    return HomeState(
      loading: loading ?? this.loading,
      todaySales: todaySales ?? this.todaySales,
      estimatedProfit: estimatedProfit ?? this.estimatedProfit,
      fiadoPending: fiadoPending ?? this.fiadoPending,
      todayExpenses: todayExpenses ?? this.todayExpenses,
      lowStockCount: lowStockCount ?? this.lowStockCount,
      recentActivity: recentActivity ?? this.recentActivity,
      error: identical(error, _unsetError) ? this.error : error as String?,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
    );
  }
}
