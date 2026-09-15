import 'package:flutter/material.dart';

/// Sombra sutil para toda superficie blanca (cards, chips, inputs).
/// Blanco puro sobre `AppColors.backgroundLight` (crema) casi no contrasta
/// — esta sombra es lo que separa esas superficies del fondo.
class AppDecorations {
  AppDecorations._();

  /// Radio de borde único para toda card/tile de la app — antes cada
  /// pantalla usaba un número distinto (8 a 20) para la misma superficie.
  static const double radius = 12;

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, 1)),
  ];

  /// Línea divisoria entre filas dentro de una card (historial, carrito,
  /// listas de movimientos). Toma el color de outline del theme activo en
  /// vez de un gris fijo, así se ve bien en modo claro y oscuro.
  static BoxDecoration rowDivider(BuildContext context) => BoxDecoration(
    border: Border(
      bottom: BorderSide(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.6),
      ),
    ),
  );

  /// Línea que separa una barra fija (footer de carrito, nav inferior) del
  /// contenido que queda arriba.
  static BoxDecoration topDivider(BuildContext context) => BoxDecoration(
    border: Border(
      top: BorderSide(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.6),
      ),
    ),
  );
}
