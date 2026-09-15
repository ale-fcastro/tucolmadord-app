import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../../../../shared/widgets/layout/app_card.dart';
import '../../../../shared/widgets/text/app_text.dart';
import '../../../business/presentation/cubit/business_cubit.dart';
import '../../../business/presentation/screens/business_settings_screen.dart';
import '../../../expenses/presentation/screens/gastos_historial_screen.dart';
import '../../../pos/presentation/screens/ventas_historial_screen.dart';
import 'proximamente_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_MoreItem>[
      _MoreItem(
        'Ventas',
        Icons.receipt_long_outlined,
        () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const VentasHistorialScreen()),
        ),
      ),
      _MoreItem(
        'Gastos',
        Icons.receipt_long_outlined,
        () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GastosHistorialScreen()),
        ),
      ),
      _MoreItem(
        'Reportes',
        Icons.insert_chart_outlined,
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ProximamenteScreen(title: 'Reportes'),
          ),
        ),
        comingSoon: true,
      ),
      _MoreItem(
        'Datos del negocio',
        Icons.storefront_outlined,
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => sl<BusinessCubit>(),
              child: const BusinessSettingsScreen(),
            ),
          ),
        ),
      ),
      _MoreItem(
        'Ayuda',
        Icons.help_outline,
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ProximamenteScreen(title: 'Ayuda'),
          ),
        ),
        comingSoon: true,
      ),
    ];

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AppHeadline('Más'),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            children: [
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: items.map((item) {
                    final outline = Theme.of(context).colorScheme.outline;
                    return InkWell(
                      onTap: item.onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                          horizontal: 10,
                        ),
                        decoration: AppDecorations.rowDivider(context),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(
                                  AppDecorations.radius,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                item.icon,
                                size: 18,
                                color: Theme.of(context).colorScheme.onSurface
                                    .withValues(
                                      alpha: item.comingSoon ? 0.4 : 0.7,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppSubtitle(
                                item.label,
                                color: item.comingSoon ? outline : null,
                              ),
                            ),
                            if (item.comingSoon) ...[
                              AppLabel('Próximamente', color: outline),
                              const SizedBox(width: 8),
                            ],
                            Icon(Icons.chevron_right, size: 18, color: outline),
                          ],
                        ),
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
  }
}

class _MoreItem {
  const _MoreItem(this.label, this.icon, this.onTap, {this.comingSoon = false});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool comingSoon;
}
