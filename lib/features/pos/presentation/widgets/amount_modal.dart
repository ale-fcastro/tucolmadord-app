import 'package:flutter/material.dart';

import '../../../../core/products/entities/product.dart';
import '../../../../core/utils/money.dart';
import '../../../../shared/theme/app_colors.dart';

Future<void> showAmountModal(
  BuildContext context, {
  required Product product,
  required void Function(double amount) onConfirm,
}) {
  final controller = TextEditingController();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
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
            Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            const Text('¿Cuánto?', style: TextStyle(fontSize: 13, color: Color(0x80201F1D))),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.6,
              children: [50, 100, 150, 200].map((v) {
                return _QuickAmount(
                  label: Money.label(v),
                  onTap: () {
                    onConfirm(v.toDouble());
                    Navigator.of(ctx).pop();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            const Text('Otro monto', style: TextStyle(fontSize: 12.5, color: Color(0x8C201F1D))),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(color: const Color(0xFFF6F1E8), borderRadius: BorderRadius.circular(13)),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                decoration: const InputDecoration(border: InputBorder.none, prefixText: 'RD\$  ', hintText: '0'),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 15)),
                onPressed: () {
                  final amount = double.tryParse(controller.text) ?? 0;
                  if (amount <= 0) return;
                  onConfirm(amount);
                  Navigator.of(ctx).pop();
                },
                child: const Text('Agregar', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _QuickAmount extends StatelessWidget {
  const _QuickAmount({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(color: const Color(0xFFF6F1E8), borderRadius: BorderRadius.circular(13)),
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
