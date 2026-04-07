import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/text_styles.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimaryStrong,
      surface: Colors.white,
      onSurface: AppColors.textPrimary,
    );

    final textTheme = TextTheme(
      headlineLarge: AppTextStyles.headline.copyWith(color: AppColors.textPrimary, fontSize: 26),
      headlineMedium: AppTextStyles.title.copyWith(color: AppColors.textPrimary, fontSize: 20),
      titleLarge: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
      titleMedium: AppTextStyles.title.copyWith(color: AppColors.textPrimary, fontSize: 16),
      titleSmall: AppTextStyles.title.copyWith(color: AppColors.textPrimary, fontSize: 14),
      bodyLarge: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
      bodyMedium: AppTextStyles.body.copyWith(color: AppColors.textPrimary, fontSize: 15),
      bodySmall: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      labelLarge: AppTextStyles.button.copyWith(color: AppColors.onPrimaryStrong),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFF0F0F0),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFFFAFAFA),
        indicatorColor: AppColors.primary.withValues(alpha: 0.22),
        labelTextStyle: WidgetStateProperty.resolveWith((s) {
          final selected = s.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? AppColors.primaryDark : AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((s) {
          final selected = s.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primaryDark : AppColors.textSecondary,
            size: 26,
          );
        }),
        height: 72,
        elevation: 3,
        shadowColor: Colors.black26,
      ),
      inputDecorationTheme: _inputLight(),
      elevatedButtonTheme: _elevatedPrimary(),
      filledButtonTheme: _filledPrimary(),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      dividerTheme: DividerThemeData(color: Colors.grey.shade300, thickness: 1),
    );
  }

  /// Giao diện chính (gamified / dark).
  static ThemeData dark() {
    const surface = AppColors.surfaceDark;
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimaryStrong,
      surface: surface,
      onSurface: AppColors.onDark,
      secondary: AppColors.gem,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
    );

    final textTheme = TextTheme(
      headlineLarge: AppTextStyles.headline.copyWith(color: AppColors.onDark, fontSize: 26),
      headlineMedium: AppTextStyles.title.copyWith(color: AppColors.onDark, fontSize: 20),
      titleLarge: AppTextStyles.title.copyWith(color: AppColors.onDark),
      titleMedium: AppTextStyles.title.copyWith(color: AppColors.onDark, fontSize: 16),
      bodyLarge: AppTextStyles.body.copyWith(color: AppColors.onDark),
      bodyMedium: AppTextStyles.body.copyWith(color: AppColors.onDark, fontSize: 15),
      bodySmall: AppTextStyles.caption.copyWith(color: AppColors.onDarkMuted),
      labelLarge: AppTextStyles.button.copyWith(color: Colors.white),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDeeper,
        foregroundColor: AppColors.onDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.bgDeeper,
        indicatorColor: AppColors.primary.withValues(alpha: 0.22),
        labelTextStyle: WidgetStateProperty.resolveWith((s) {
          final selected = s.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? AppColors.primary : AppColors.onDarkMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((s) {
          final selected = s.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primary : AppColors.onDarkMuted,
            size: 26,
          );
        }),
        height: 72,
        elevation: 8,
        shadowColor: Colors.black54,
      ),
      inputDecorationTheme: _inputDark(),
      elevatedButtonTheme: _elevatedPrimary(),
      filledButtonTheme: _filledPrimary(),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gem,
          side: const BorderSide(color: Color(0xFF52656E)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF2A3F4A), thickness: 1),
    );
  }

  static InputDecorationTheme _inputLight() {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  static InputDecorationTheme _inputDark() {
    const borderSide = BorderSide(color: Color(0xFF3D4F58));
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: borderSide,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: borderSide,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      labelStyle: const TextStyle(color: AppColors.onDarkMuted),
      hintStyle: const TextStyle(color: AppColors.onDarkSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  static ElevatedButtonThemeData _elevatedPrimary() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimaryStrong,
        elevation: 0,
        shadowColor: AppColors.primaryDark,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: AppTextStyles.button.copyWith(color: AppColors.onPrimaryStrong),
      ),
    );
  }

  static FilledButtonThemeData _filledPrimary() {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimaryStrong,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: AppTextStyles.button.copyWith(color: AppColors.onPrimaryStrong, fontSize: 15),
      ),
    );
  }
}
