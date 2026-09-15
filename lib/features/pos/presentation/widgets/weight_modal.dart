import 'package:flutter/material.dart';

import '../../../../core/products/entities/product.dart';
import '../../../../core/utils/money.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/layout/app_card.dart';
import '../../../../shared/widgets/text/app_text.dart';

Future<void> showWeightModal(
  BuildContext context, {
  required Product product,
  required void Function(double qty) onConfirm,
  double? initialQty,
}) {
  final controller = TextEditingController(
    text: initialQty == null
        ? ''
        : (initialQty % 1 == 0 ? initialQty.toStringAsFixed(0) : initialQty.toString()),
  );
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setState) {
        final rawQty = double.tryParse(controller.text.replaceAll(',', '.'));
        final hasError = controller.text.isNotEmpty && (rawQty == null || rawQty <= 0);
        final qty = (rawQty != null && rawQty > 0) ? rawQty : 0.0;
        final amount = qty * (product.price ?? 0);
        return Padding(
          padding: EdgeInsets.only(left: 18, right: 18, top: 18, bottom: 18 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTitle(product.name),
              const SizedBox(height: 2),
              const AppLabel('Cantidad / peso'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(AppDecorations.radius)),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        decoration: const InputDecoration(border: InputBorder.none, hintText: '0'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(AppDecorations.radius)),
                    child: const AppLabel('lb'),
                  ),
                ],
              ),
              if (hasError) ...[
                const SizedBox(height: 6),
                const Text(
                  'Ingresa un peso válido',
                  style: TextStyle(fontSize: 12, color: AppColors.error),
                ),
              ],
              const SizedBox(height: 14),
              AppCard(
                color: AppColors.infoBg,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppLabel('Monto', color: AppColors.primary),
                    AppTitle(Money.label(amount), color: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Agregar',
                  enabled: rawQty != null && rawQty > 0,
                  onPressed: () {
                    onConfirm(qty);
                    Navigator.of(ctx).pop();
                  },
                ),
              ),
            ],
          ),
        );
      });
    },
  );
}
