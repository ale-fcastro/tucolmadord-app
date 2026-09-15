import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/money.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_search_field.dart';
import '../../../../shared/widgets/layout/app_card.dart';
import '../../../../shared/widgets/layout/app_empty_state.dart';
import '../../../../shared/widgets/text/app_text.dart';
import '../cubit/fiados_cubit.dart';
import 'fiado_detail_screen.dart';

class FiadosScreen extends StatelessWidget {
  const FiadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FiadosCubit, FiadosState>(
      builder: (context, state) {
        final cubit = context.read<FiadosCubit>();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  const Expanded(child: AppHeadline('Fiados')),
                  PrimaryButton(
                    label: 'Nuevo cliente',
                    icon: Icons.add,
                    onPressed: () => _showAddCustomerDialog(context, cubit),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: AppCard(
                color: AppColors.errorBg,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppLabel('Total pendiente', color: AppColors.error),
                      AppAmount(
                        Money.label(state.totalPending),
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: AppSearchField(
                hintText: 'Buscar cliente...',
                onChanged: cubit.setSearch,
              ),
            ),
            Expanded(
              child: state.loading
                  ? const Center(child: CircularProgressIndicator())
                  : state.visible.isEmpty
                  ? AppEmptyState(
                      icon: Icons.handshake_outlined,
                      message: state.search.isEmpty
                          ? 'Aún no tienes clientes con fiado — el fiado es el crédito informal '
                                'que le das a tus clientes de confianza.'
                          : 'No hay clientes que coincidan con la búsqueda.',
                      actionLabel: 'Agregar cliente',
                      onAction: () => _showAddCustomerDialog(context, cubit),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      itemCount: state.visible.length,
                      itemBuilder: (context, i) {
                        final c = state.visible[i];
                        final isPaidOff = c.balance <= 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Opacity(
                            opacity: isPaidOff ? 0.55 : 1,
                            child: AppCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 13,
                              ),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => FiadoDetailScreen(
                                    customerId: c.id,
                                    parentCubit: cubit,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 19,
                                    backgroundColor: AppColors.fiadoBg,
                                    child: Text(
                                      c.initial,
                                      style: const TextStyle(
                                        color: AppColors.fiado,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: AppSubtitle(c.name)),
                                  AppSubtitle(
                                    Money.label(c.balance),
                                    color: c.balance > 0
                                        ? AppColors.error
                                        : AppColors.success,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showAddCustomerDialog(BuildContext context, FiadosCubit cubit) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo cliente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Nombre'),
            ),
            const SizedBox(height: 8),
            const AppDescription(
              'Esto solo guarda el contacto. Para dar fiado, entra al cliente y registra el cargo.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                cubit.addCustomer(controller.text.trim());
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
