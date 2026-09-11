import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/money.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../../domain/entities/day_summary.dart';
import '../cubit/closing_cubit.dart';

class CierreScreen extends StatelessWidget {
  const CierreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ClosingCubit>(),
      child: const _CierreView(),
    );
  }
}

class _CierreView extends StatelessWidget {
  const _CierreView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: BlocBuilder<ClosingCubit, DaySummary>(
          builder: (context, summary) {
            final cubit = context.read<ClosingCubit>();
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 16, 4),
                  child: Row(
                    children: [
                      IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new, size: 20)),
                      const Text('Cierre del día', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDecorations.cardShadow),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _Row('Ventas', Money.label(summary.totalSales)),
                            _Row('Cantidad de ventas', '${summary.salesCount}'),
                            _Row('Efectivo', Money.label(summary.cashTotal)),
                            _Row('Transferencias', Money.label(summary.transferTotal)),
                            _Row('Fiado', Money.label(summary.fiadoTotal)),
                            _Row('Gastos', Money.label(summary.expensesTotal)),
                            _Row('Ganancia estimada', Money.label(summary.estimatedProfit), bold: true, color: AppColors.success, last: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (summary.closed)
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              const Icon(Icons.check_circle_outline, size: 34, color: AppColors.success),
                              const SizedBox(height: 8),
                              const Text('Día cerrado', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.success)),
                              const SizedBox(height: 2),
                              const Text('Esto fue lo que pasó hoy.', style: TextStyle(fontSize: 12.5, color: Color(0x8C201F1D))),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, padding: const EdgeInsets.symmetric(vertical: 13)),
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Volver a Inicio', style: TextStyle(fontWeight: FontWeight.w800)),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                            onPressed: cubit.closeDay,
                            child: const Text('CERRAR DÍA', style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.bold = false, this.color, this.last = false});
  final String label;
  final String value;
  final bool bold;
  final Color? color;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: last ? null : const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0F201F1D)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13.5, fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: bold ? null : const Color(0x99201F1D))),
          Text(value, style: TextStyle(fontSize: bold ? 16 : 14.5, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
