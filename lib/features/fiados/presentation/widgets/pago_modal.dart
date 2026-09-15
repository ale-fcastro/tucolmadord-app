import 'package:flutter/material.dart';

import '../../../../core/utils/money.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/selectable_chip.dart';
import '../../../../shared/widgets/feedback/app_notification.dart';
import '../../../../shared/widgets/text/app_text.dart';
import '../cubit/fiado_detail_cubit.dart';

Future<void> showPagoModal(BuildContext context, FiadoDetailCubit cubit) {
  final controller = TextEditingController();
  String method = 'Efectivo';
  bool isSubmitting = false;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setState) {
        final customer = cubit.state.customer!;
        final amount = double.tryParse(controller.text) ?? 0;
        final nuevoPendiente = (customer.balance - amount).clamp(0, double.infinity);
        final overpays = amount > customer.balance;
        final isZero = controller.text.isNotEmpty && amount <= 0;
        final errorText = overpays
            ? 'El monto no puede superar lo que debe (${Money.label(customer.balance)})'
            : isZero
                ? 'Ingresa un monto válido'
                : null;
        final canSubmit = amount > 0 && !overpays && !isSubmitting;
        // Chips fijos, sin ofrecer un monto que sobrepase el saldo actual.
        final quickAmounts = <double>{customer.balance, 200, 500}
            .where((v) => v > 0 && v <= customer.balance)
            .toList()
          ..sort();

        Future<void> submit() async {
          if (!canSubmit) return;
          setState(() => isSubmitting = true);
          try {
            await cubit.registerPayment(amount: amount, paymentMethod: method);
            if (ctx.mounted) Navigator.of(ctx).pop();
          } catch (_) {
            if (ctx.mounted) {
              AppNotification.error(ctx, 'No se pudo registrar el pago. Intenta de nuevo.');
              setState(() => isSubmitting = false);
            }
          }
        }

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTitle('Registrar pago — ${customer.name}'),
                        const SizedBox(height: 4),
                        AppLabel('Debe actualmente: ${Money.label(customer.balance)}'),
                        const SizedBox(height: 14),
                        if (quickAmounts.isNotEmpty)
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 2.2,
                            children: quickAmounts.map((v) {
                              final selected = amount == v;
                              return SelectableChip(
                                label: Money.label(v),
                                selected: selected,
                                onTap: () => setState(() => controller.text = v.toStringAsFixed(0)),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 12),
                        const AppLabel('Monto recibido'),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(AppDecorations.radius),
                            border: errorText != null ? Border.all(color: AppColors.error) : null,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            decoration: const InputDecoration(border: InputBorder.none, prefixText: 'RD\$  ', hintText: '0'),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        if (errorText != null) ...[
                          const SizedBox(height: 6),
                          AppLabel(errorText, color: AppColors.error),
                        ],
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            SelectableChip(
                              label: 'Efectivo',
                              selected: method == 'Efectivo',
                              onTap: () => setState(() => method = 'Efectivo'),
                              expand: true,
                            ),
                            const SizedBox(width: 8),
                            SelectableChip(
                              label: 'Transferencia',
                              selected: method == 'Transferencia',
                              onTap: () => setState(() => method = 'Transferencia'),
                              expand: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(AppDecorations.radius)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const AppLabel('Nuevo pendiente'),
                              AppTitle(Money.label(nuevoPendiente)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: 'REGISTRAR PAGO',
                      enabled: canSubmit,
                      isLoading: isSubmitting,
                      onPressed: submit,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}
