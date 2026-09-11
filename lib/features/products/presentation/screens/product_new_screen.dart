import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/feedback/app_notification.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../../../core/products/entities/product.dart';
import '../cubit/products_cubit.dart';

class ProductNewScreen extends StatefulWidget {
  const ProductNewScreen({super.key});

  @override
  State<ProductNewScreen> createState() => _ProductNewScreenState();
}

class _ProductNewScreenState extends State<ProductNewScreen> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _minStockCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  bool _trackStock = false;
  SellMode _mode = SellMode.unit;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _minStockCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      AppNotification.error(context, 'Ponle un nombre al producto');
      return;
    }
    setState(() => _saving = true);
    try {
      await context.read<ProductsCubit>().addProduct(
            name: _nameCtrl.text.trim(),
            price: _mode == SellMode.amount ? null : double.tryParse(_priceCtrl.text),
            cost: double.tryParse(_costCtrl.text),
            mode: _mode,
            category: 'Otros',
            trackStock: _trackStock,
            stock: _trackStock ? double.tryParse(_stockCtrl.text) : null,
            minStock: _trackStock ? double.tryParse(_minStockCtrl.text) : null,
          );
      if (!mounted) return;
      AppNotification.success(context, 'Producto guardado');
      Navigator.of(context).pop();
    } catch (e, st) {
      debugPrint('addProduct failed: $e\n$st');
      if (!mounted) return;
      setState(() => _saving = false);
      AppNotification.error(context, 'No se pudo guardar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Nuevo producto',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nombre', style: TextStyle(fontSize: 12.5, color: Color(0x8C201F1D))),
            const SizedBox(height: 6),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Ej. Salami')),
            const SizedBox(height: 14),
            if (_mode != SellMode.amount) ...[
              const Text('Precio de venta', style: TextStyle(fontSize: 12.5, color: Color(0x8C201F1D))),
              const SizedBox(height: 6),
              TextField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixText: 'RD\$  ', hintText: '0'),
              ),
              const SizedBox(height: 16),
            ],
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: AppDecorations.cardShadow),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('¿Quieres controlar inventario?', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  ),
                  Switch(
                    value: _trackStock,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primary,
                    onChanged: (v) => setState(() => _trackStock = v),
                  ),
                ],
              ),
            ),
            if (_trackStock) ...[
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: AppDecorations.cardShadow),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _NumberField(label: 'Stock actual', controller: _stockCtrl),
                    const SizedBox(height: 12),
                    _NumberField(label: 'Stock mínimo', controller: _minStockCtrl),
                    const SizedBox(height: 12),
                    _NumberField(label: 'Costo', controller: _costCtrl),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Text('¿Cómo se vende?', style: TextStyle(fontSize: 12.5, color: Color(0x8C201F1D))),
            const SizedBox(height: 8),
            Row(
              children: [
                _ModeChip(label: 'Por unidad', selected: _mode == SellMode.unit, onTap: () => setState(() => _mode = SellMode.unit)),
                const SizedBox(width: 8),
                _ModeChip(label: 'Por peso', selected: _mode == SellMode.weight, onTap: () => setState(() => _mode = SellMode.weight)),
                const SizedBox(width: 8),
                _ModeChip(label: 'Por importe', selected: _mode == SellMode.amount, onTap: () => setState(() => _mode = SellMode.amount)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(label: 'Guardar producto', isLoading: _saving, onPressed: _save),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0x8C201F1D))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF6F1E8),
            hintText: '0',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? AppColors.infoBg : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppDecorations.cardShadow,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.primary : const Color(0xFF201F1D),
            ),
          ),
        ),
      ),
    );
  }
}
