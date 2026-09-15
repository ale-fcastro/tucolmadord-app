import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/customers/entities/customer.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/customers/customers_repository.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/layout/app_card.dart';
import '../../../../shared/widgets/layout/app_empty_state.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../../../shared/widgets/text/app_text.dart';
import '../cubit/fiado_detail_cubit.dart';
import '../cubit/fiados_cubit.dart';
import '../widgets/pago_modal.dart';

class FiadoDetailScreen extends StatelessWidget {
  const FiadoDetailScreen({super.key, required this.customerId, required this.parentCubit});

  final String customerId;
  final FiadosCubit parentCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FiadoDetailCubit(sl<CustomersRepository>(), customerId),
      child: _FiadoDetailView(parentCubit: parentCubit),
    );
  }
}

class _FiadoDetailView extends StatelessWidget {
  const _FiadoDetailView({required this.parentCubit});
  final FiadosCubit parentCubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FiadoDetailCubit, FiadoDetailState>(
      builder: (context, state) {
        final cubit = context.read<FiadoDetailCubit>();
        if (state.loading || state.customer == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final customer = state.customer!;
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) parentCubit.load();
          },
          child: AppScaffold(
            title: customer.name,
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      AppCard(
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            children: [
                              const AppLabel('Te debe'),
                              AppAmount(
                                Money.label(customer.balance),
                                color: customer.balance > 0 ? AppColors.error : AppColors.success,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const AppSubtitle('Historial'),
                      const SizedBox(height: 8),
                      state.movements.isEmpty
                          ? const AppEmptyState(
                              message: 'Sin movimientos todavía',
                              icon: Icons.receipt_long_outlined,
                            )
                          : AppCard(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Column(
                                children: state.movements.map((m) {
                                  final isPago = m.type == FiadoMovementType.pago;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: AppDecorations.rowDivider(context),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              AppDescription(m.note ?? (isPago ? 'Pago recibido' : 'Compra')),
                                              const SizedBox(height: 2),
                                              AppLabel(
                                                dateTimeLabel(m.createdAt),
                                                color: Theme.of(context).colorScheme.outline,
                                              ),
                                            ],
                                          ),
                                        ),
                                        AppSubtitle(
                                          '${isPago ? '−' : '+'}${Money.label(m.amount)}',
                                          color: isPago ? AppColors.success : AppColors.error,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: AppDecorations.topDivider(context).copyWith(color: Theme.of(context).colorScheme.surface),
                  child: SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(label: 'REGISTRAR PAGO', onPressed: () => showPagoModal(context, cubit)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
