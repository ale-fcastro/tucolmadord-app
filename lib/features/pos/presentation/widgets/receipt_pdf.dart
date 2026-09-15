import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/utils/money.dart';
import '../../../../core/utils/time_format.dart';
import '../../../business/data/business_models.dart';
import '../../domain/entities/sale.dart';

/// Genera el PDF de una venta con la marca del negocio (logo/nombre/RNC si
/// el dueño los cargó, o "TuColmadoRD" como respaldo) para Compartir/
/// Imprimir. Formato angosto tipo rollo térmico — se usa tanto para el
/// recibo recién completado como para reimprimir una venta del historial.
Future<Uint8List> buildReceiptPdf({
  required Sale sale,
  required List<SaleItem> items,
  BusinessProfile? profile,
}) async {
  final doc = pw.Document();

  pw.MemoryImage? logo;
  final logoBase64 = profile?.logoBase64;
  if (logoBase64 != null) {
    try {
      logo = pw.MemoryImage(base64Decode(logoBase64));
    } catch (_) {
      logo = null;
    }
  }

  final businessName = (profile?.name.trim().isNotEmpty ?? false)
      ? profile!.name.trim()
      : 'TuColmadoRD';
  const smallGray = pw.TextStyle(fontSize: 9, color: PdfColors.grey700);
  final bold = pw.TextStyle(fontWeight: pw.FontWeight.bold);

  pw.Widget row(String label, String value, {pw.TextStyle? style}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: style),
            pw.Text(value, style: style),
          ],
        ),
      );

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      margin: const pw.EdgeInsets.all(18),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Column(
            children: [
              if (logo != null) ...[
                pw.Container(height: 60, width: 60, child: pw.Image(logo)),
                pw.SizedBox(height: 6),
              ],
              pw.Text(
                businessName,
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              if (profile?.rnc?.isNotEmpty ?? false)
                pw.Text(
                  'RNC: ${profile!.rnc}',
                  style: smallGray,
                  textAlign: pw.TextAlign.center,
                ),
              if (profile?.address?.isNotEmpty ?? false)
                pw.Text(
                  profile!.address!,
                  style: smallGray,
                  textAlign: pw.TextAlign.center,
                ),
              if (profile?.phone?.isNotEmpty ?? false)
                pw.Text(
                  'Tel. ${profile!.phone}',
                  style: smallGray,
                  textAlign: pw.TextAlign.center,
                ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Divider(),
          row(
            'Factura',
            '#${sale.id.substring(0, 6).toUpperCase()}',
            style: bold,
          ),
          row('Fecha', _fullDateLabel(sale.createdAt)),
          pw.Divider(),
          pw.SizedBox(height: 4),
          ...items.map(
            (item) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(child: pw.Text(item.productName)),
                      pw.Text(Money.label(item.lineTotal)),
                    ],
                  ),
                  if (item.unitPrice != null)
                    pw.Text(
                      '${_quantityLabel(item.quantity)} x ${Money.label(item.unitPrice!)}',
                      style: smallGray,
                    ),
                ],
              ),
            ),
          ),
          pw.Divider(),
          row(
            'TOTAL',
            Money.label(sale.total),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
          ),
          pw.SizedBox(height: 6),
          row('Método', paymentMethodLabel(sale.paymentMethod)),
          if (sale.receivedAmount != null)
            row('Recibido', Money.label(sale.receivedAmount!)),
          if (sale.changeAmount != null)
            row('Cambio', Money.label(sale.changeAmount!)),
          pw.SizedBox(height: 20),
          pw.Text(
            '¡Gracias por su compra!',
            style: smallGray,
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    ),
  );

  return doc.save();
}

String _quantityLabel(double quantity) {
  final rounded = quantity.roundToDouble();
  if ((quantity - rounded).abs() < 0.001) return rounded.toStringAsFixed(0);
  return quantity.toStringAsFixed(2);
}

String _fullDateLabel(DateTime dt) {
  final day = dt.day.toString().padLeft(2, '0');
  final month = dt.month.toString().padLeft(2, '0');
  return '$day/$month/${dt.year} ${timeLabel(dt)}';
}
