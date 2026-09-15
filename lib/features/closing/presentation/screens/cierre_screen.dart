import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/money.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/feedback/app_notification.dart';
import '../../../../shared/widgets/layout/app_card.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../../../shared/widgets/text/app_text.dart';
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

  Future<void> _confirmAndClose(
    BuildContext context,
    ClosingCubit cubit,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Cerrar el día?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cerrar día'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await cubit.closeDay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Cierre del día',
      actions: [
        BlocBuilder<ClosingCubit, ClosingState>(
          buildWhen: (previous, current) =>
              previous.isSendingEmail != current.isSendingEmail,
          builder: (context, state) {
            if (state.isSendingEmail) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return IconButton(
              icon: const Icon(Icons.mail_outline),
              tooltip: 'Enviar reporte por correo',
              onPressed: () => context.read<ClosingCubit>().sendReportEmail(),
            );
          },
        ),
      ],
      body: BlocConsumer<ClosingCubit, ClosingState>(
        listenWhen: (previous, current) =>
            (current.errorMessage != null &&
                current.errorMessage != previous.errorMessage) ||
            (current.successMessage != null &&
                current.successMessage != previous.successMessage),
        listener: (context, state) {
          if (state.errorMessage != null) {
            AppNotification.error(context, state.errorMessage!);
          }
          if (state.successMessage != null) {
            AppNotification.success(context, state.successMessage!);
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final cubit = context.read<ClosingCubit>();
          final summary = state.summary;
          final profitColor = summary.estimatedProfit >= 0
              ? AppColors.success
              : AppColors.error;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              const AppLabel('VENTAS'),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _Row('Ventas', Money.label(summary.totalSales)),
                    _Row(
                      'Cantidad de ventas',
                      '${summary.salesCount}',
                      last: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const AppLabel('MÉTODOS DE PAGO'),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _Row('Efectivo', Money.label(summary.cashTotal)),
                    _Row('Transferencias', Money.label(summary.transferTotal)),
                    _Row('Fiado', Money.label(summary.fiadoTotal), last: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const AppLabel('GASTOS Y GANANCIA'),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _Row('Gastos', Money.label(summary.expensesTotal)),
                    _HeroRow(
                      'Ganancia estimada',
                      Money.label(summary.estimatedProfit),
                      color: profitColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (summary.closed)
                AppCard(
                  color: AppColors.successBg,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 34,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 8),
                      const AppSubtitle(
                        'Día cerrado',
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 2),
                      const AppLabel('Esto fue lo que pasó hoy.'),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          label: 'Volver a Inicio',
                          color: AppColors.success,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'CERRAR DÍA',
                    isLoading: state.isClosing,
                    onPressed: () => _confirmAndClose(context, cubit),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.last = false});
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: last ? null : AppDecorations.rowDivider(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [AppLabel(label), AppSubtitle(value)],
      ),
    );
  }
}

/// Fila protagonista para el resultado neto del día ("Ganancia estimada") —
/// usa AppAmount en vez de AppTitle para que el número domine visualmente,
/// como el resto de los números "hero" de la app.
class _HeroRow extends StatelessWidget {
  const _HeroRow(this.label, this.value, {this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSubtitle(label),
          const SizedBox(height: 4),
          AppAmount(value, color: color),
        ],
      ),
    );
  }
}
