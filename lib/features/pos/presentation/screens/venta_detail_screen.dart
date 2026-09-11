import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../../data/sales_repository.dart';
import '../../domain/entities/sale.dart';

class VentaDetailScreen extends StatelessWidget {
  const VentaDetailScreen({super.key, required this.sale});
  final Sale sale;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 16, 4),
              child: Row(
                children: [
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new, size: 20)),
                  Text('Venta #${sale.id.substring(0, 6)}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<SaleItem>>(
                future: sl<SalesRepository>().getItems(sale.id),
                builder: (context, snapshot) {
                  final items = snapshot.data ?? const [];
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDecorations.cardShadow),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Fecha', style: TextStyle(fontSize: 13, color: Color(0x8C201F1D))),
                                Text(timeLabel(sale.createdAt), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Método', style: TextStyle(fontSize: 13, color: Color(0x8C201F1D))),
                                Text(paymentMethodLabel(sale.paymentMethod), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 6),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text('Productos', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDecorations.cardShadow),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: items
                              .map((l) => Container(
                                    padding: const EdgeInsets.symmetric(vertical: 9),
                                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0F201F1D)))),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(l.productName, style: const TextStyle(fontSize: 13)),
                                        Text(Money.label(l.lineTotal), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(color: AppColors.infoBg, borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            Text(Money.label(sale.total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
