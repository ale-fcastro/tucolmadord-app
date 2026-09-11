import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/money.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../../../products/presentation/cubit/products_cubit.dart';
import '../../../products/presentation/cubit/products_state.dart';
import '../../../pos/presentation/screens/ventas_historial_screen.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onGoInventarioLow});

  final VoidCallback onGoInventarioLow;

  String get _dateLabel {
    const days = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.loading) return const Center(child: CircularProgressIndicator());
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('TuColmadoRD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Text('CM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Hola 👋', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(_dateLabel, style: const TextStyle(fontSize: 13, color: Color(0x8C201F1D))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100), boxShadow: AppDecorations.cardShadow),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.smartphone, size: 12, color: Color(0xA6201F1D)),
                  SizedBox(width: 6),
                  Text('Guardado en este dispositivo', style: TextStyle(fontSize: 12, color: Color(0xA6201F1D))),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ventas de hoy', style: TextStyle(fontSize: 13, color: Colors.white70)),
                  Text(Money.label(state.todaySales), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5)),
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
              childAspectRatio: 1.75,
              children: [
                _StatTile(icon: Icons.trending_up, color: AppColors.success, bg: AppColors.successBg, label: 'Ganancia est.', value: Money.label(state.estimatedProfit)),
                _StatTile(icon: Icons.groups_outlined, color: AppColors.error, bg: AppColors.errorBg, label: 'Fiado pendiente', value: Money.label(state.fiadoPending)),
                _StatTile(icon: Icons.receipt_long_outlined, color: AppColors.primary, bg: AppColors.infoBg, label: 'Gastos de hoy', value: Money.label(state.todayExpenses)),
                _StatTile(icon: Icons.warning_amber_rounded, color: AppColors.warning, bg: AppColors.warningBg, label: 'Productos bajos', value: '${state.lowStockCount}'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Actividad reciente', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VentasHistorialScreen())),
                  child: const Text('Ver todas', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDecorations.cardShadow),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: state.recentActivity.isEmpty
                    ? [const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('Sin actividad todavía', style: TextStyle(color: Color(0x80201F1D))))]
                    : state.recentActivity.map((a) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0F201F1D)))),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(color: a.bgColor, borderRadius: BorderRadius.circular(10)),
                                alignment: Alignment.center,
                                child: Icon(a.icon, size: 16, color: a.color),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(a.title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                                    Text(relativeLabel(a.time), style: const TextStyle(fontSize: 11.5, color: Color(0x80201F1D))),
                                  ],
                                ),
                              ),
                              Text(Money.label(a.amount), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
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
                  context.read<ProductsCubit>().setFilter(ProductsFilter.lowStock);
                  onGoInventarioLow();
                },
                child: Container(
                  decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.warning),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('${state.lowStockCount} productos con poco inventario',
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.warning)),
                      ),
                      const Text('Ver →', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.warning)),
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
  const _StatTile({required this.icon, required this.color, required this.bg, required this.label, required this.value});
  final IconData icon;
  final Color color;
  final Color bg;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDecorations.cardShadow),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9)),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0x8C201F1D))),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
