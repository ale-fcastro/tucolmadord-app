import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/money.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/feedback/app_notification.dart';
import '../../../../shared/widgets/layout/app_card.dart';
import '../../../../shared/widgets/text/app_text.dart';
import '../../../business/data/business_profile_store.dart';
import '../../domain/entities/sale.dart';
import '../cubit/pos_cubit.dart';
import '../widgets/receipt_pdf.dart';

class SaleCompleteScreen extends StatelessWidget {
  const SaleCompleteScreen({super.key});

  Future<void> _share(BuildContext context, Sale sale) async {
    final bytes = await _buildPdf(sale);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'factura_${sale.id.substring(0, 6)}.pdf',
    );
  }

  Future<void> _print(BuildContext context, Sale sale) async {
    final bytes = await _buildPdf(sale);
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'factura_${sale.id.substring(0, 6)}.pdf',
    );
  }

  Future<Uint8List> _buildPdf(Sale sale) {
    final profile = sl<BusinessProfileStore>().cached;
    return buildReceiptPdf(sale: sale, items: sale.items, profile: profile);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PosCubit>();
    final sale = cubit.state.lastSale;
    final profile = sl<BusinessProfileStore>().cached;
    final logoBase64 = profile?.logoBase64;
    final businessName = (profile?.name.trim().isNotEmpty ?? false)
        ? profile!.name.trim()
        : 'TuColmadoRD';

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _BrandBadge(logoBase64: logoBase64),
                    const SizedBox(height: 10),
                    AppSubtitle(businessName, textAlign: TextAlign.center),
                    if (profile?.rnc?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 2),
                      AppLabel('RNC: ${profile!.rnc}'),
                    ],
                    const SizedBox(height: 16),
                    const Icon(
                      Icons.check_circle_outline,
                      size: 44,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 10),
                    const AppTitle('Venta completada'),
                    const SizedBox(height: 6),
                    AppAmount(Money.label(sale?.total ?? 0)),
                    const SizedBox(height: 18),
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...?sale?.items.map(
                              (l) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    AppLabel(l.productName),
                                    AppSubtitle(Money.label(l.lineTotal)),
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(height: 1),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const AppSubtitle('Método'),
                                AppSubtitle(
                                  sale != null
                                      ? paymentMethodLabel(sale.paymentMethod)
                                      : '',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        label: 'NUEVA VENTA',
                        onPressed: () {
                          cubit.startNewSale();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            icon: Icons.share_outlined,
                            label: 'Compartir',
                            onPressed: sale == null
                                ? null
                                : () async {
                                    try {
                                      await _share(context, sale);
                                    } catch (_) {
                                      if (context.mounted)
                                        AppNotification.error(
                                          context,
                                          'No se pudo compartir la factura.',
                                        );
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SecondaryButton(
                            icon: Icons.print_outlined,
                            label: 'Imprimir',
                            onPressed: sale == null
                                ? null
                                : () async {
                                    try {
                                      await _print(context, sale);
                                    } catch (_) {
                                      if (context.mounted)
                                        AppNotification.error(
                                          context,
                                          'No se pudo imprimir la factura.',
                                        );
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandBadge extends StatelessWidget {
  const _BrandBadge({this.logoBase64});

  final String? logoBase64;

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;
    if (logoBase64 != null) {
      try {
        image = MemoryImage(base64Decode(logoBase64!));
      } catch (_) {
        image = null;
      }
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        shape: BoxShape.circle,
        image: image != null
            ? DecorationImage(image: image, fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: image == null
          ? const Icon(
              Icons.storefront_outlined,
              size: 26,
              color: AppColors.primary,
            )
          : null,
    );
  }
}
