import 'package:flutter/material.dart';

/// Sombra sutil para toda superficie blanca (cards, chips, inputs).
/// Blanco puro sobre `AppColors.backgroundLight` (crema) casi no contrasta
/// — esta sombra es lo que separa esas superficies del fondo.
class AppDecorations {
  AppDecorations._();

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, 1)),
  ];
}
