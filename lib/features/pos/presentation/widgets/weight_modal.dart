import 'package:flutter/material.dart';

import '../../../../core/products/entities/product.dart';
import '../../../../core/utils/money.dart';
import '../../../../shared/theme/app_colors.dart';

Future<void> showWeightModal(
  BuildContext context, {
  required Product product,
  required void Function(double qty) onConfirm,
}) {
  final controller = TextEditingController();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setState) {
        final qty = double.tryParse(controller.text) ?? 0;
        final amount = qty * (product.price ?? 0);
        return Padding(
          padding: EdgeInsets.only(left: 18, right: 18, top: 18, bottom: 18 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              const Text('Cantidad / peso', style: TextStyle(fontSize: 13, color: Color(0x80201F1D))),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: const Color(0xFFF6F1E8), borderRadius: BorderRadius.circular(13)),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        decoration: const InputDecoration(border: InputBorder.none, hintText: '0'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: const Color(0xFFF6F1E8), borderRadius: BorderRadius.circular(13)),
                    child: const Text('lb', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0x8C201F1D))),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(color: AppColors.infoBg, borderRadius: BorderRadius.circular(13)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Monto', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    Text(Money.label(amount), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 15)),
                  onPressed: qty > 0
                      ? () {
                          onConfirm(qty);
                          Navigator.of(ctx).pop();
                        }
                      : null,
                  child: const Text('Agregar', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        );
      });
    },
  );
}
