import 'package:flutter/material.dart';

import '../../../../shared/theme/app_decorations.dart';
import '../../../expenses/presentation/screens/gastos_historial_screen.dart';
import '../../../pos/presentation/screens/ventas_historial_screen.dart';
import 'proximamente_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_MoreItem>[
      _MoreItem('Ventas', Icons.receipt_long_outlined, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VentasHistorialScreen()))),
      _MoreItem('Gastos', Icons.attach_money, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GastosHistorialScreen()))),
      _MoreItem('Reportes', Icons.insert_chart_outlined, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProximamenteScreen(title: 'Reportes')))),
      _MoreItem('Configuración', Icons.settings_outlined, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProximamenteScreen(title: 'Configuración')))),
      _MoreItem('Ayuda', Icons.help_outline, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProximamenteScreen(title: 'Ayuda')))),
    ];

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Align(alignment: Alignment.centerLeft, child: Text('Más', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700))),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDecorations.cardShadow),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: items
                      .map((item) => InkWell(
                            onTap: item.onTap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0F201F1D)))),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(color: const Color(0xFFF6F1E8), borderRadius: BorderRadius.circular(10)),
                                    alignment: Alignment.center,
                                    child: Icon(item.icon, size: 18, color: const Color(0xFF5B564E)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(item.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                                  const Icon(Icons.chevron_right, size: 18, color: Color(0x59201F1D)),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
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
  const _MoreItem(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;
}
