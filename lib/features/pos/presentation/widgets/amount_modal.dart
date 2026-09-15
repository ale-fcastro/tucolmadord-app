import 'package:flutter/material.dart';

import '../../../../core/products/entities/product.dart';
import '../../../../core/utils/money.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/selectable_chip.dart';
import '../../../../shared/widgets/inputs/app_boxed_field.dart';
import '../../../../shared/widgets/text/app_text.dart';

Future<void> showAmountModal(
  BuildContext context, {
  required Product product,
  required void Function(double amount) onConfirm,
  double? initialAmount,
}) {
  final controller = TextEditingController(
    text: initialAmount == null
        ? ''
        : (initialAmount % 1 == 0
              ? initialAmount.toStringAsFixed(0)
              : initialAmount.toString()),
  );
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 18,
          bottom: 18 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTitle(product.name),
            const SizedBox(height: 2),
            const AppLabel('¿Cuánto?'),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.6,
              children: [50, 100, 150, 200].map((v) {
                return SelectableChip(
                  label: Money.label(v),
                  selected: false,
                  onTap: () {
                    onConfirm(v.toDouble());
                    Navigator.of(ctx).pop();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            const AppLabel('Otro monto'),
            const SizedBox(height: 6),
            AppBoxedField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              prefixText: 'RD\$  ',
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Agregar',
                onPressed: () {
                  final amount = double.tryParse(controller.text) ?? 0;
                  if (amount <= 0) return;
                  onConfirm(amount);
                  Navigator.of(ctx).pop();
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
