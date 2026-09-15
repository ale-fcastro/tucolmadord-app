import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../../../../shared/widgets/layout/app_empty_state.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../../../shared/widgets/text/app_text.dart';
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

  void _reload() {
    setState(() {
      _future = sl<SalesRepository>().getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Ventas',
      body: FutureBuilder<List<Sale>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return AppEmptyState(
              message: 'No se pudo cargar el historial de ventas',
              icon: Icons.error_outline,
              actionLabel: 'Reintentar',
              onAction: _reload,
            );
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final sales = snapshot.data!;
          if (sales.isEmpty) {
            return const AppEmptyState(
              message: 'Sin ventas todavía',
              icon: Icons.receipt_long_outlined,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: sales.length,
            itemBuilder: (context, i) {
              final s = sales[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 1),
                decoration: AppDecorations.rowDivider(context),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => VentaDetailScreen(sale: s))),
                  title: AppSubtitle('Venta #${s.id.substring(0, 6)}'),
                  subtitle: AppLabel('${dateTimeLabel(s.createdAt)} · ${paymentMethodLabel(s.paymentMethod)}'),
                  trailing: AppSubtitle(Money.label(s.total)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
