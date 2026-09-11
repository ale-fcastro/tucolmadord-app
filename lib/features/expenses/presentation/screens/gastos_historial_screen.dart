import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../../data/expenses_repository.dart';
import '../../domain/entities/expense.dart';

class GastosHistorialScreen extends StatefulWidget {
  const GastosHistorialScreen({super.key});

  @override
  State<GastosHistorialScreen> createState() => _GastosHistorialScreenState();
}

class _GastosHistorialScreenState extends State<GastosHistorialScreen> {
  late Future<List<Expense>> _future;

  @override
  void initState() {
    super.initState();
    _future = sl<ExpensesRepository>().getAll();
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
                  const Text('Gastos', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Expense>>(
                future: _future,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final expenses = snapshot.data!;
                  final total = expenses.fold<double>(0, (s, e) => s + e.amount);
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Gastos totales', style: TextStyle(fontSize: 12.5, color: Color(0xFF8A4E0A))),
                            Text(Money.label(total), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.warning)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (expenses.isEmpty)
                        const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: Text('Sin gastos todavía')))
                      else
                        Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDecorations.cardShadow),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Column(
                            children: expenses
                                .map((e) => Container(
                                      padding: const EdgeInsets.symmetric(vertical: 11),
                                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0F201F1D)))),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(e.concept, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                                                Text('${e.category} · ${timeLabel(e.createdAt)}', style: const TextStyle(fontSize: 11.5, color: Color(0x80201F1D))),
                                              ],
                                            ),
                                          ),
                                          Text(Money.label(e.amount), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                    ],
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
