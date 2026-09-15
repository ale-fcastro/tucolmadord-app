import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../../../../shared/widgets/layout/app_card.dart';
import '../../../../shared/widgets/layout/app_empty_state.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../../../shared/widgets/text/app_text.dart';
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

  void _reload() {
    setState(() {
      _future = sl<ExpensesRepository>().getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Gastos',
      body: FutureBuilder<List<Expense>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return AppEmptyState(
              message: 'No se pudo cargar el historial de gastos',
              icon: Icons.error_outline,
              actionLabel: 'Reintentar',
              onAction: _reload,
            );
          }
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final expenses = snapshot.data!;
          final total = expenses.fold<double>(0, (s, e) => s + e.amount);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              AppCard(
                color: AppColors.infoBg,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppLabel(
                        'Gastos totales (histórico)',
                        color: AppColors.info,
                      ),
                      AppTitle(Money.label(total), color: AppColors.info),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (expenses.isEmpty)
                const AppEmptyState(
                  message: 'Sin gastos todavía',
                  icon: Icons.receipt_long_outlined,
                )
              else
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: expenses.length,
                    itemBuilder: (context, i) {
                      final e = expenses[i];
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: AppDecorations.rowDivider(context),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppSubtitle(e.concept),
                                  AppLabel(
                                    '${e.category} · ${dateTimeLabel(e.createdAt)}',
                                  ),
                                ],
                              ),
                            ),
                            AppSubtitle(Money.label(e.amount)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
