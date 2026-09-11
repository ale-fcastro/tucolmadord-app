import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/money.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../../domain/entities/sale.dart';
import '../cubit/pos_cubit.dart';

class SaleCompleteScreen extends StatelessWidget {
  const SaleCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PosCubit>();
    final sale = cubit.state.lastSale;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
          child: Column(
            children: [
              const Icon(Icons.check_circle_outline, size: 52, color: AppColors.success),
              const SizedBox(height: 14),
              const Text('Venta completada', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(Money.label(sale?.total ?? 0), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDecorations.cardShadow),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...?sale?.items.map((l) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l.productName, style: const TextStyle(fontSize: 13, color: Color(0xA6201F1D))),
                              Text(Money.label(l.lineTotal), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Método', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                        Text(sale != null ? paymentMethodLabel(sale.paymentMethod) : '', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () {
                    cubit.startNewSale();
                    Navigator.of(context).pop();
                  },
                  child: const Text('NUEVA VENTA', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.share_outlined, size: 16),
                      label: const Text('Compartir'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.print_outlined, size: 16),
                      label: const Text('Imprimir'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
