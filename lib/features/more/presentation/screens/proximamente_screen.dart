import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';

/// Placeholder para secciones que todavía no se implementan (reportes con
/// envío por correo, configuración, etc.) — evita rutas rotas mientras el
/// resto de la app ya funciona de punta a punta.
class ProximamenteScreen extends StatelessWidget {
  const ProximamenteScreen({super.key, required this.title});
  final String title;

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
                  Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const Expanded(
              child: Center(
                child: Text('Próximamente', style: TextStyle(fontSize: 14, color: Color(0x8C201F1D))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
