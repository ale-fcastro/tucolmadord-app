import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/selectable_chip.dart';
import '../../../../shared/widgets/inputs/app_boxed_field.dart';
import '../../../../shared/widgets/layout/app_card.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../../../shared/widgets/text/app_text.dart';
import '../cubit/expenses_cubit.dart';

const _categories = [
  'Mercancía',
  'Servicios',
  'Transporte',
  'Personal',
  'Otro',
];

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
  final _montoCtrl = TextEditingController();
  final _conceptoCtrl = TextEditingController();
  String _categoria = 'Mercancía';

  Future<void> _registrar(ExpensesCubit cubit) async {
    final amount = double.tryParse(_montoCtrl.text) ?? 0;
    if (amount <= 0 || _conceptoCtrl.text.trim().isEmpty) return;
    await cubit.addExpense(
      amount: amount,
      concept: _conceptoCtrl.text.trim(),
      category: _categoria,
    );
    _montoCtrl.clear();
    _conceptoCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExpensesCubit>();
    return AppScaffold(
      title: 'Registrar gasto',
      body: BlocBuilder<ExpensesCubit, ExpensesState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              const AppLabel('Monto'),
              const SizedBox(height: 6),
              AppBoxedField(
                controller: _montoCtrl,
                keyboardType: TextInputType.number,
                prefixText: 'RD\$  ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              const AppLabel('Concepto'),
              const SizedBox(height: 6),
              AppBoxedField(
                controller: _conceptoCtrl,
                hintText: 'Ej. Compra de hielo',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              const AppLabel('Categoría'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((c) {
                  return SelectableChip(
                    label: c,
                    selected: _categoria == c,
                    onTap: () => setState(() => _categoria = c),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'REGISTRAR GASTO',
                  onPressed: () => _registrar(cubit),
                ),
              ),
              const SizedBox(height: 24),
              const AppSubtitle('Gastos de hoy'),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: state.today.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: AppLabel('Sin gastos hoy'),
                          ),
                        ]
                      : state.today.asMap().entries.map((entry) {
                          final last = entry.key == state.today.length - 1;
                          final e = entry.value;
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: last
                                ? null
                                : AppDecorations.rowDivider(context),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppSubtitle(e.concept),
                                      AppLabel(
                                        '${e.category} · ${timeLabel(e.createdAt)}',
                                      ),
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
          );
        },
      ),
    );
  }
}
