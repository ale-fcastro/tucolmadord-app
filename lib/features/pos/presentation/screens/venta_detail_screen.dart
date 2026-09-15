import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../../core/customers/customers_repository.dart';
import '../../../../core/customers/entities/customer.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/feedback/app_notification.dart';
import '../../../../shared/widgets/layout/app_card.dart';
import '../../../../shared/widgets/layout/app_empty_state.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../../../shared/widgets/text/app_text.dart';
import '../../../business/data/business_profile_store.dart';
import '../../data/sales_repository.dart';
import '../../domain/entities/sale.dart';
import '../widgets/receipt_pdf.dart';

class VentaDetailScreen extends StatefulWidget {
  const VentaDetailScreen({super.key, required this.sale});
  final Sale sale;

  @override
  State<VentaDetailScreen> createState() => _VentaDetailScreenState();
}

class _VentaDetailScreenState extends State<VentaDetailScreen> {
  late Future<List<SaleItem>> _itemsFuture;
  Future<Customer?>? _customerFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = sl<SalesRepository>().getItems(widget.sale.id);
    final customerId = widget.sale.customerId;
    if (customerId != null) {
      _customerFuture = sl<CustomersRepository>().getById(customerId);
    }
  }

  void _reloadItems() {
    setState(() {
      _itemsFuture = sl<SalesRepository>().getItems(widget.sale.id);
    });
  }

  Future<void> _share(List<SaleItem> items) async {
    try {
      final bytes = await _buildPdf(items);
      await Printing.sharePdf(bytes: bytes, filename: 'factura_${widget.sale.id.substring(0, 6)}.pdf');
    } catch (_) {
      if (mounted) AppNotification.error(context, 'No se pudo compartir la factura.');
    }
  }

  Future<void> _print(List<SaleItem> items) async {
    try {
      final bytes = await _buildPdf(items);
      await Printing.layoutPdf(onLayout: (_) async => bytes, name: 'factura_${widget.sale.id.substring(0, 6)}.pdf');
    } catch (_) {
      if (mounted) AppNotification.error(context, 'No se pudo imprimir la factura.');
    }
  }

  Future<Uint8List> _buildPdf(List<SaleItem> items) {
    final profile = sl<BusinessProfileStore>().cached;
    return buildReceiptPdf(sale: widget.sale, items: items, profile: profile);
  }

  @override
  Widget build(BuildContext context) {
    final sale = widget.sale;
    return AppScaffold(
      title: 'Venta #${sale.id.substring(0, 6)}',
      body: FutureBuilder<List<SaleItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return AppEmptyState(
              message: 'No se pudo cargar el detalle de la venta',
              icon: Icons.error_outline,
              actionLabel: 'Reintentar',
              onAction: _reloadItems,
            );
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppLabel('Fecha'),
                        AppSubtitle(dateTimeLabel(sale.createdAt)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppLabel('Método'),
                        AppSubtitle(paymentMethodLabel(sale.paymentMethod)),
                      ],
                    ),
                    if (sale.customerId != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AppLabel('Cliente'),
                          FutureBuilder<Customer?>(
                            future: _customerFuture,
                            builder: (context, customerSnapshot) {
                              return AppSubtitle(customerSnapshot.data?.name ?? '—');
                            },
                          ),
                        ],
                      ),
                    ],
                    if (sale.receivedAmount != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AppLabel('Recibido'),
                          AppSubtitle(Money.label(sale.receivedAmount!)),
                        ],
                      ),
                    ],
                    if (sale.changeAmount != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AppLabel('Cambio'),
                          AppSubtitle(Money.label(sale.changeAmount!)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const AppSubtitle('Productos'),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: items
                      .map((l) => Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: AppDecorations.rowDivider(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppDescription(l.productName),
                                      if (l.unitPrice != null) ...[
                                        const SizedBox(height: 2),
                                        AppLabel('${_quantityLabel(l.quantity)} x ${Money.label(l.unitPrice!)}'),
                                      ],
                                    ],
                                  ),
                                ),
                                AppSubtitle(Money.label(l.lineTotal)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                color: AppColors.infoBg,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppSubtitle('Total', color: AppColors.primary),
                    AppTitle(Money.label(sale.total), color: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(icon: Icons.share_outlined, label: 'Compartir', onPressed: () => _share(items)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SecondaryButton(icon: Icons.print_outlined, label: 'Imprimir', onPressed: () => _print(items)),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// "3" para cantidades enteras, "1.5" para ventas por peso/fracción.
String _quantityLabel(double quantity) {
  final rounded = quantity.roundToDouble();
  if ((quantity - rounded).abs() < 0.001) return rounded.toStringAsFixed(0);
  return quantity.toStringAsFixed(2);
}
