import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final onBackground = isDark
        ? AppColors.onBackgroundDark
        : AppColors.onBackgroundLight;
    final onSurface = isDark
        ? AppColors.onSurfaceDark
        : AppColors.onSurfaceLight;
    final outline = isDark ? AppColors.outlineDark : AppColors.outlineLight;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      error: AppColors.error,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      outline: outline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: AppTextStyles.fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleMedium.copyWith(color: onSurface),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: outline.withValues(alpha: 0.3)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: AppTextStyles.titleSmall,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: AppTextStyles.titleSmall,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        // Todo campo de entrada de la app pasa por este theme — inputs con
        // decoración por defecto (AppTextField y cualquier TextFormField sin
        // override) heredan fill + bordes de acá. Antes el fill era igual al
        // background de la pantalla y el borde era `BorderSide.none` en todos
        // los estados, así que un input no se distinguía del fondo ni al
        // enfocarlo — quedaba invisible (ver AppColors.surfaceVariantLight).
        filled: true,
        fillColor: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: outline.withValues(alpha: 0.5)),
        ),
        labelStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.error)) {
            return const TextStyle(color: AppColors.error);
          }
          if (states.contains(WidgetState.focused)) {
            return const TextStyle(color: AppColors.primary);
          }
          return TextStyle(color: onSurface.withValues(alpha: 0.6));
        }),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.error)) {
            return const TextStyle(color: AppColors.error);
          }
          if (states.contains(WidgetState.focused)) {
            return const TextStyle(color: AppColors.primary);
          }
          return TextStyle(color: onSurface.withValues(alpha: 0.6));
        }),
        hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.4)),
        prefixIconColor: onSurface.withValues(alpha: 0.5),
        suffixIconColor: onSurface.withValues(alpha: 0.5),
      ),
      textTheme: TextTheme(
        headlineSmall: AppTextStyles.headlineSmall.copyWith(
          color: onBackground,
        ),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: onBackground),
        titleSmall: AppTextStyles.titleSmall.copyWith(color: onBackground),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: onBackground),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: onBackground),
        labelSmall: AppTextStyles.labelSmall.copyWith(
          color: onBackground.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
