import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_text_styles.dart';

/// Pastilla seleccionable — categorías, filtros, pestañas de método de pago,
/// montos rápidos. Antes cada pantalla reconstruía esto a mano con su propio
/// radio y su propio gris; este widget es el único lugar que lo define.
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.expand = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;
    final content = GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : surface,
          borderRadius: BorderRadius.circular(AppDecorations.radius),
          boxShadow: selected ? null : AppDecorations.cardShadow,
        ),
        child: Text(
          label,
          style: AppTextStyles.titleSmall.copyWith(
            color: selected ? AppColors.onPrimary : onSurface,
          ),
        ),
      ),
    );
    return expand ? Expanded(child: content) : content;
  }
}
