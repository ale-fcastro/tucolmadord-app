import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/selectable_chip.dart';
import '../../../../shared/widgets/feedback/app_notification.dart';
import '../../../../shared/widgets/layout/app_card.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../../../shared/widgets/text/app_text.dart';
import '../cubit/expenses_cubit.dart';

const _categories = ['Mercancía', 'Servicios', 'Transporte', 'Personal', 'Otro'];

class GastoScreen extends StatelessWidget {
  const GastoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ExpensesCubit>(),
      child: const _GastoView(),
    );
  }
}

class _GastoView extends StatefulWidget {
  const _GastoView();

  @override
  State<_GastoView> createState() => _GastoViewState();
}

class _GastoViewState extends State<_GastoView> {
  final _formKey = GlobalKey<FormState>();
  final _montoCtrl = TextEditingController();
  final _conceptoCtrl = TextEditingController();
  String _categoria = 'Mercancía';
  bool _saving = false;

  @override
  void dispose() {
    _montoCtrl.dispose();
    _conceptoCtrl.dispose();
    super.dispose();
  }

  String? _montoValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa un monto';
    final n = double.tryParse(value.trim());
    if (n == null) return 'Número inválido';
    if (n <= 0) return 'Debe ser mayor que 0';
    return null;
  }

  String? _conceptoValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa un concepto';
    return null;
  }

  Future<void> _registrar(ExpensesCubit cubit) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = double.parse(_montoCtrl.text.trim());
    setState(() => _saving = true);
    try {
      await cubit.addExpense(amount: amount, concept: _conceptoCtrl.text.trim(), category: _categoria);
      if (!mounted) return;
      _montoCtrl.clear();
      _conceptoCtrl.clear();
      AppNotification.success(context, 'Gasto registrado');
    } catch (e, st) {
      debugPrint('addExpense failed: $e\n$st');
      if (!mounted) return;
      AppNotification.error(context, 'No se pudo registrar el gasto. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExpensesCubit>();
    return AppScaffold(
      title: 'Registrar gasto',
      body: BlocBuilder<ExpensesCubit, ExpensesState>(
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                const AppLabel('Monto'),
                const SizedBox(height: 6),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextFormField(
                    controller: _montoCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(border: InputBorder.none, prefixText: 'RD\$  ', hintText: '0'),
                    validator: _montoValidator,
                  ),
                ),
                const SizedBox(height: 4),
                const AppLabel('Los montos se muestran redondeados a pesos enteros'),
                const SizedBox(height: 16),
                const AppLabel('Concepto'),
                const SizedBox(height: 6),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextFormField(
                    controller: _conceptoCtrl,
                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Ej. Compra de hielo'),
                    validator: _conceptoValidator,
                  ),
                ),
                const SizedBox(height: 16),
                const AppLabel('Categoría'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((c) {
                    final selected = _categoria == c;
                    return SelectableChip(label: c, selected: selected, onTap: () => setState(() => _categoria = c));
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'REGISTRAR GASTO',
                    isLoading: _saving,
                    enabled: !_saving,
                    onPressed: () => _registrar(cubit),
                  ),
                ),
                const SizedBox(height: 20),
                const AppSubtitle('Gastos de hoy'),
                const SizedBox(height: 8),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: state.today.isEmpty
                        ? [const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: AppLabel('Sin gastos hoy'))]
                        : state.today.map((e) {
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: AppDecorations.rowDivider(context),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AppSubtitle(e.concept),
                                        AppLabel('${e.category} · ${timeLabel(e.createdAt)}'),
                                      ],
                                    ),
                                  ),
                                  AppSubtitle(Money.label(e.amount)),
                                ],
                              ),
                            );
                          }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
