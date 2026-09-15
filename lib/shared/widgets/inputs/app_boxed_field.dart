import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';

/// Campo "en caja" para entradas numéricas grandes sin label flotante (monto,
/// peso, cantidad) — usado en modales y formularios rápidos. Reusa el mismo
/// fill + sombra que [AppCard]/[AppSearchField] en vez de que cada pantalla
/// reconstruya el `Container` a mano con su propio color; antes varias
/// pantallas usaban `AppColors.backgroundLight` de relleno, el mismo color
/// del fondo detrás del modal, así que el campo casi no se distinguía.
class AppBoxedField extends StatelessWidget {
  const AppBoxedField({
    super.key,
    this.controller,
    this.keyboardType,
    this.prefixText,
    this.hintText = '0',
    this.style,
    this.onChanged,
    this.autofocus = false,
    this.hasError = false,
  });

  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? prefixText;
  final String hintText;
  final TextStyle? style;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDecorations.radius),
        boxShadow: AppDecorations.cardShadow,
        border: hasError
            ? Border.all(color: AppColors.error, width: 1.5)
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        autofocus: autofocus,
        style:
            style ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixText: prefixText,
          hintText: hintText,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
