import 'package:flutter/material.dart';
import '../../theme/app_decorations.dart';

/// Barra de búsqueda estándar — antes cada pantalla (inventario, fiados,
/// vender) reconstruía el mismo Container+TextField a mano.
class AppSearchField extends StatelessWidget {
  const AppSearchField({super.key, required this.hintText, required this.onChanged});

  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDecorations.radius),
        boxShadow: AppDecorations.cardShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          prefixIcon: const Icon(Icons.search, size: 20),
        ),
      ),
    );
  }
}
