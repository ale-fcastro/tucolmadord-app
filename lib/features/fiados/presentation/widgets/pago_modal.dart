import 'package:flutter/material.dart';

import '../../../../core/utils/money.dart';
import '../../../../shared/theme/app_colors.dart';
import '../cubit/fiado_detail_cubit.dart';

Future<void> showPagoModal(BuildContext context, FiadoDetailCubit cubit) {
  final controller = TextEditingController();
  String method = 'Efectivo';
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setState) {
        final customer = cubit.state.customer!;
        final amount = double.tryParse(controller.text) ?? 0;
        final nuevoPendiente = (customer.balance - amount).clamp(0, double.infinity);
        return Padding(
          padding: EdgeInsets.only(left: 18, right: 18, top: 18, bottom: 18 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Registrar pago — ${customer.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Debe actualmente: ${Money.label(customer.balance)}', style: const TextStyle(fontSize: 12.5, color: Color(0x80201F1D))),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.2,
                children: [customer.balance, 200, 500].map((v) {
                  return GestureDetector(
                    onTap: () => setState(() => controller.text = v.toStringAsFixed(0)),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: const Color(0xFFF6F1E8), borderRadius: BorderRadius.circular(11)),
                      child: Text(Money.label(v), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              const Text('Monto recibido', style: TextStyle(fontSize: 12.5, color: Color(0x8C201F1D))),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(color: const Color(0xFFF6F1E8), borderRadius: BorderRadius.circular(13)),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(border: InputBorder.none, prefixText: 'RD\$  ', hintText: '0'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => method = 'Efectivo'),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(color: method == 'Efectivo' ? AppColors.primary : const Color(0xFFF6F1E8), borderRadius: BorderRadius.circular(11)),
                        child: Text('Efectivo', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: method == 'Efectivo' ? Colors.white : const Color(0xFF201F1D))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => method = 'Transferencia'),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(color: method == 'Transferencia' ? AppColors.primary : const Color(0xFFF6F1E8), borderRadius: BorderRadius.circular(11)),
                        child: Text('Transferencia', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: method == 'Transferencia' ? Colors.white : const Color(0xFF201F1D))),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(color: const Color(0xFFF6F1E8), borderRadius: BorderRadius.circular(13)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Nuevo pendiente', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0x99201F1D))),
                    Text(Money.label(nuevoPendiente), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 15)),
                  onPressed: amount > 0
                      ? () async {
                          await cubit.registerPayment(amount: amount, paymentMethod: method);
                          if (ctx.mounted) Navigator.of(ctx).pop();
                        }
                      : null,
                  child: const Text('REGISTRAR PAGO', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        );
      });
    },
  );
}
