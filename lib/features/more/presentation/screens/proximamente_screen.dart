import 'package:flutter/material.dart';

import '../../../../shared/widgets/layout/app_empty_state.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';

/// Placeholder para secciones que todavía no se implementan (reportes con
/// envío por correo, configuración, etc.) — evita rutas rotas mientras el
/// resto de la app ya funciona de punta a punta.
class ProximamenteScreen extends StatelessWidget {
  const ProximamenteScreen({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      body: AppEmptyState(
        message: '$title estará disponible pronto',
        icon: Icons.hourglass_empty,
        actionLabel: 'Volver',
        onAction: () => Navigator.pop(context),
      ),
    );
  }
}
