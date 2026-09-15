import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/selectable_chip.dart';
import '../../../../shared/widgets/feedback/app_notification.dart';
import '../../../../shared/widgets/layout/app_card.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../../../shared/widgets/text/app_text.dart';
import '../../../../core/products/entities/product.dart';
import '../cubit/products_cubit.dart';

const _categories = ['Abarrotes', 'Bebidas', 'Snacks', 'Limpieza', 'Cuidado personal', 'Otros'];

class ProductNewScreen extends StatefulWidget {
  const ProductNewScreen({super.key, this.product});

  /// Cuando no es null, la pantalla edita este producto en vez de crear uno.
  final Product? product;

  @override
  State<ProductNewScreen> createState() => _ProductNewScreenState();
}

class _ProductNewScreenState extends State<ProductNewScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.product?.name);
  late final _priceCtrl = TextEditingController(text: widget.product?.price?.toStringAsFixed(2));
  late final _stockCtrl = TextEditingController(text: widget.product?.stock?.toStringAsFixed(2));
  late final _minStockCtrl = TextEditingController(text: widget.product?.minStock?.toStringAsFixed(2));
  late final _costCtrl = TextEditingController(text: widget.product?.cost?.toStringAsFixed(2));
  late bool _trackStock = widget.product?.trackStock ?? false;
  late SellMode _mode = widget.product?.mode ?? SellMode.unit;
  late String _category = widget.product?.category ?? 'Otros';
  bool _saving = false;

  bool get _isEditing => widget.product != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _minStockCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  String? _requiredNumberValidator(String? value, {bool allowZero = false}) {
    if (value == null || value.trim().isEmpty) return 'Campo requerido';
    final n = double.tryParse(value.trim());
    if (n == null) return 'Número inválido';
    if (allowZero ? n < 0 : n <= 0) {
      return allowZero ? 'No puede ser negativo' : 'Debe ser mayor que 0';
    }
    return null;
  }

  String? _optionalNumberValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final n = double.tryParse(value.trim());
    if (n == null) return 'Número inválido';
    if (n < 0) return 'No puede ser negativo';
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final cubit = context.read<ProductsCubit>();
      final price = _mode == SellMode.amount ? null : double.tryParse(_priceCtrl.text.trim());
      final cost = double.tryParse(_costCtrl.text.trim());
      final stock = _trackStock ? double.tryParse(_stockCtrl.text.trim()) : null;
      final minStock = _trackStock ? double.tryParse(_minStockCtrl.text.trim()) : null;
      if (_isEditing) {
        await cubit.updateProduct(widget.product!.copyWith(
          name: _nameCtrl.text.trim(),
          price: price,
          cost: cost,
          mode: _mode,
          category: _category,
          trackStock: _trackStock,
          stock: stock,
          minStock: minStock,
        ));
      } else {
        await cubit.addProduct(
          name: _nameCtrl.text.trim(),
          price: price,
          cost: cost,
          mode: _mode,
          category: _category,
          trackStock: _trackStock,
          stock: stock,
          minStock: minStock,
        );
      }
      if (!mounted) return;
      AppNotification.success(context, _isEditing ? 'Producto actualizado' : 'Producto guardado');
      Navigator.of(context).pop();
    } catch (e, st) {
      debugPrint('save product failed: $e\n$st');
      if (!mounted) return;
      AppNotification.error(context, 'No se pudo guardar el producto. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: _isEditing ? 'Editar producto' : 'Nuevo producto',
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppLabel('Nombre'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(hintText: 'Ej. Salami'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ponle un nombre al producto' : null,
              ),
              const SizedBox(height: 14),
              if (_mode != SellMode.amount) ...[
                const AppLabel('Precio de venta'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  decoration: const InputDecoration(prefixText: 'RD\$  ', hintText: '0'),
                  validator: (v) => _requiredNumberValidator(v),
                ),
                const SizedBox(height: 16),
              ],
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: AppSubtitle('¿Quieres controlar inventario?'),
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
                AppCard(
                  child: Column(
                    children: [
                      _NumberField(
                        label: 'Stock actual',
                        controller: _stockCtrl,
                        validator: (v) => _requiredNumberValidator(v, allowZero: true),
                      ),
                      const SizedBox(height: 12),
                      _NumberField(
                        label: 'Stock mínimo',
                        controller: _minStockCtrl,
                        validator: _optionalNumberValidator,
                      ),
                      const SizedBox(height: 12),
                      _NumberField(
                        label: 'Costo',
                        controller: _costCtrl,
                        validator: (v) => _requiredNumberValidator(v),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              const AppLabel('Categoría'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((c) {
                  return SelectableChip(
                    label: c,
                    selected: _category == c,
                    onTap: () => setState(() => _category = c),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const AppLabel('¿Cómo se vende?'),
              const SizedBox(height: 8),
              Row(
                children: [
                  SelectableChip(
                    label: 'Por unidad',
                    selected: _mode == SellMode.unit,
                    onTap: () => setState(() => _mode = SellMode.unit),
                    expand: true,
                  ),
                  const SizedBox(width: 8),
                  SelectableChip(
                    label: 'Por peso',
                    selected: _mode == SellMode.weight,
                    onTap: () => setState(() => _mode = SellMode.weight),
                    expand: true,
                  ),
                  const SizedBox(width: 8),
                  SelectableChip(
                    label: 'Por importe',
                    selected: _mode == SellMode.amount,
                    onTap: () => setState(() => _mode = SellMode.amount),
                    expand: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: _isEditing ? 'Guardar cambios' : 'Guardar producto',
                  isLoading: _saving,
                  enabled: !_saving,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.label, required this.controller, this.validator});
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          decoration: const InputDecoration(hintText: '0'),
          validator: validator,
        ),
      ],
    );
  }
}
