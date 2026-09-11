import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../data/sales_repository.dart';
import '../../domain/entities/sale.dart';
import 'venta_detail_screen.dart';

class VentasHistorialScreen extends StatefulWidget {
  const VentasHistorialScreen({super.key});

  @override
  State<VentasHistorialScreen> createState() => _VentasHistorialScreenState();
}

class _VentasHistorialScreenState extends State<VentasHistorialScreen> {
  late Future<List<Sale>> _future;

  @override
  void initState() {
    super.initState();
    _future = sl<SalesRepository>().getAll();
  }

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
                  const Text('Ventas', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Sale>>(
                future: _future,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final sales = snapshot.data!;
                  if (sales.isEmpty) return const Center(child: Text('Sin ventas todavía'));
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: sales.length,
                    itemBuilder: (context, i) {
                      final s = sales[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 1),
                        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0F201F1D)))),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => VentaDetailScreen(sale: s))),
                          title: Text('Venta #${s.id.substring(0, 6)}', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                          subtitle: Text('${timeLabel(s.createdAt)} · ${paymentMethodLabel(s.paymentMethod)}', style: const TextStyle(fontSize: 11.5, color: Color(0x80201F1D))),
                          trailing: Text(Money.label(s.total), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        ),
                      );
                    },
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
