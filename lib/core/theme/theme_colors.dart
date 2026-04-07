import 'package:flutter/material.dart';

import '../constants/colors.dart';

/// Màu nền / chữ phụ thuộc [ThemeData] (sáng vs tối).
extension BeeWiseThemeContext on BuildContext {
  Color get beeSurfaceCard =>
      Theme.of(this).cardTheme.color ??
      (Theme.of(this).brightness == Brightness.dark
          ? AppColors.surfaceElevated
          : const Color(0xFFF0F0F0));

  Color get beeSectionBg =>
      Theme.of(this).brightness == Brightness.dark ? AppColors.bgDeeper : const Color(0xFFF5F5F5);

  Color get beeOnSurface => Theme.of(this).colorScheme.onSurface;

  Color get beeMuted =>
      Theme.of(this).brightness == Brightness.dark ? AppColors.onDarkMuted : AppColors.textSecondary;

  Color get beeSecondaryLabel =>
      Theme.of(this).brightness == Brightness.dark ? AppColors.onDarkSecondary : AppColors.textSecondary;
}
