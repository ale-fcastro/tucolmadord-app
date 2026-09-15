import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/money.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../../../../shared/widgets/layout/app_card.dart';
import '../../../../shared/widgets/layout/app_empty_state.dart';
import '../../../../shared/widgets/text/app_text.dart';
import '../../../products/presentation/cubit/products_cubit.dart';
import '../../../products/presentation/cubit/products_state.dart';
import '../../../pos/presentation/screens/ventas_historial_screen.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onGoInventarioLow});

  final VoidCallback onGoInventarioLow;

  String get _dateLabel {
    const days = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ];
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.loading && !state.hasLoadedOnce) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null && !state.hasLoadedOnce) {
          return AppEmptyState(
            message: state.error!,
            icon: Icons.error_outline,
            actionLabel: 'Reintentar',
            onAction: () => context.read<HomeCubit>().load(),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'TuColmadoRD',
                    image: true,
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Image(
                        image: AssetImage('assets/images/logo-full.png'),
                        height: 26,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.infoBg,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset('assets/images/logo-mark.png'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const AppHeadline('Hola 👋'),
            const SizedBox(height: 2),
            AppLabel(_dateLabel),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(100),
                boxShadow: AppDecorations.cardShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.smartphone,
                    size: 12,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  const AppLabel('Guardado en este dispositivo'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDecorations.radius),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLabel('Ventas de hoy', color: Colors.white70),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: AppAmount(
                      Money.label(state.todaySales),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                _StatTile(
                  icon: Icons.trending_up,
                  color: AppColors.success,
                  bg: AppColors.successBg,
                  label: 'Ganancia est.',
                  value: Money.label(state.estimatedProfit),
                ),
                _StatTile(
                  icon: Icons.groups_outlined,
                  color: AppColors.error,
                  bg: AppColors.errorBg,
                  label: 'Fiado pendiente',
                  value: Money.label(state.fiadoPending),
                ),
                _StatTile(
                  icon: Icons.receipt_long_outlined,
                  color: AppColors.primary,
                  bg: AppColors.infoBg,
                  label: 'Gastos de hoy',
                  value: Money.label(state.todayExpenses),
                ),
                _StatTile(
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  bg: AppColors.warningBg,
                  label: 'Productos bajos',
                  value: '${state.lowStockCount}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppSubtitle('Actividad reciente'),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const VentasHistorialScreen(),
                    ),
                  ),
                  child: const AppLabel('Ver todas', color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: state.recentActivity.isEmpty
                    ? [
                        const AppEmptyState(
                          message: 'Sin actividad todavía',
                          icon: Icons.receipt_long_outlined,
                        ),
                      ]
                    : state.recentActivity.map((a) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: AppDecorations.rowDivider(context),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: a.bgColor,
                                  borderRadius: BorderRadius.circular(
                                    AppDecorations.radius,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(a.icon, size: 16, color: a.color),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    AppLabel(relativeLabel(a.time)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: AppSubtitle(Money.label(a.amount)),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
              ),
            ),
            if (state.lowStockCount > 0) ...[
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {
                  context.read<ProductsCubit>().setFilter(
                    ProductsFilter.lowStock,
                  );
                  onGoInventarioLow();
                },
                child: AppCard(
                  color: AppColors.warningBg,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppSubtitle(
                          '${state.lowStockCount} productos con poco inventario',
                          color: AppColors.warning,
                        ),
                      ),
                      const AppLabel('Ver →', color: AppColors.warning),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.color,
    required this.bg,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color color;
  final Color bg;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppDecorations.radius),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 8),
          AppLabel(label),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AppTitle(value),
          ),
        ],
      ),
    );
  }
}
