import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary — azul TuColmadoRD
  static const Color primary = Color(0xFF2A5CDB);
  static const Color primaryLight = Color(0xFF5079E1);
  static const Color primaryDark = Color(0xFF224BB4);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Secondary — verde (ganancia / éxito)
  static const Color secondary = Color(0xFF1F9254);
  static const Color secondaryLight = Color(0xFF47A673);
  static const Color secondaryDark = Color(0xFF197845);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Semantic — igual al mockup
  static const Color success = Color(0xFF1F9254);
  static const Color successBg = Color(0xFFE8F6EE);
  static const Color warning = Color(0xFFB4690E);
  static const Color warningBg = Color(0xFFFBF0DF);
  static const Color error = Color(0xFFD92D2B);
  static const Color errorBg = Color(0xFFFCEAEA);
  static const Color info = Color(0xFF2A5CDB);
  static const Color infoBg = Color(0xFFEAF0FE);

  // Acento fiados (morado)
  static const Color fiado = Color(0xFF6B4FCB);
  static const Color fiadoBg = Color(0xFFEFEAFB);

  // Light
  static const Color backgroundLight = Color(0xFFF6F1E8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  // Antes igual a `backgroundLight` — un input "filled" con ese color se
  // volvía invisible sobre el fondo de la pantalla. Reusa el blanco de
  // `surfaceLight` (mismo tono que cards/search) para que cualquier campo
  // interactivo se distinga del fondo sin inventar un color nuevo.
  static const Color surfaceVariantLight = Color(0xFFFFFFFF);
  static const Color onBackgroundLight = Color(0xFF201F1D);
  static const Color onSurfaceLight = Color(0xFF201F1D);
  static const Color outlineLight = Color(0xFFDAD4C7);

  // Dark
  static const Color backgroundDark = Color(0xFF0F1117);
  static const Color surfaceDark = Color(0xFF1A1D27);
  static const Color surfaceVariantDark = Color(0xFF262A38);
  static const Color onBackgroundDark = Color(0xFFE6E1E5);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);
  static const Color outlineDark = Color(0xFF49454F);
}
