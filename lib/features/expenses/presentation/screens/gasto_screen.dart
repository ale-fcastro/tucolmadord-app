import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../shared/theme/app_colors.dart';
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
  final _montoCtrl = TextEditingController();
  final _conceptoCtrl = TextEditingController();
  String _categoria = 'Mercancía';

  Future<void> _registrar(ExpensesCubit cubit) async {
    final amount = double.tryParse(_montoCtrl.text) ?? 0;
    if (amount <= 0 || _conceptoCtrl.text.trim().isEmpty) return;
    await cubit.addExpense(amount: amount, concept: _conceptoCtrl.text.trim(), category: _categoria);
    _montoCtrl.clear();
    _conceptoCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExpensesCubit>();
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: BlocBuilder<ExpensesCubit, ExpensesState>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 16, 4),
                  child: Row(
                    children: [
                      IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new, size: 20)),
                      const Text('Registrar gasto', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      const Text('Monto', style: TextStyle(fontSize: 12.5, color: Color(0x8C201F1D))),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: TextField(
                          controller: _montoCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          decoration: const InputDecoration(border: InputBorder.none, prefixText: 'RD\$  ', hintText: '0'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Concepto', style: TextStyle(fontSize: 12.5, color: Color(0x8C201F1D))),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: TextField(
                          controller: _conceptoCtrl,
                          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Ej. Compra de hielo'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Categoría', style: TextStyle(fontSize: 12.5, color: Color(0x8C201F1D))),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((c) {
                          final selected = _categoria == c;
                          return GestureDetector(
                            onTap: () => setState(() => _categoria = c),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                              decoration: BoxDecoration(color: selected ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(11)),
                              child: Text(c, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: selected ? Colors.white : const Color(0xFF201F1D))),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 15)),
                          onPressed: () => _registrar(cubit),
                          child: const Text('REGISTRAR GASTO', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Gastos de hoy', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Column(
                          children: state.today.isEmpty
                              ? [const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('Sin gastos hoy', style: TextStyle(color: Color(0x80201F1D))))]
                              : state.today.map((e) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0F201F1D)))),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(e.concept, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                              Text('${e.category} · ${timeLabel(e.createdAt)}', style: const TextStyle(fontSize: 11.5, color: Color(0x80201F1D))),
                                            ],
                                          ),
                                        ),
                                        Text(Money.label(e.amount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
