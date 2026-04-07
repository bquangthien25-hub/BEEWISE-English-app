import 'package:flutter/material.dart';

/// Bảng màu BeeWise — gamified (dark + vàng / amber chủ đạo).
abstract final class AppColors {
  static const Color primary = Color(0xFFFFC107);
  static const Color primaryDark = Color(0xFFF57C00);
  static const Color primaryLight = Color(0xFFFFE082);
  /// Chữ / icon trên nền vàng (nút, thẻ gradient).
  static const Color onPrimaryStrong = Color(0xFF1A1200);

  /// Nền chính (Duolingo-like)
  static const Color bgDark = Color(0xFF131F24);
  static const Color bgDeeper = Color(0xFF0D1114);
  static const Color surfaceDark = Color(0xFF1A2C35);
  static const Color surfaceElevated = Color(0xFF22343F);

  static const Color background = Color(0xFFF7F7F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF3C3C3C);
  static const Color textSecondary = Color(0xFF777777);

  /// Chữ trên nền tối (tăng độ tương phản để dễ đọc)
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color onDarkMuted = Color(0xFFCBD5E1);
  static const Color onDarkSecondary = Color(0xFF94A3B8);

  static const Color error = Color(0xFFFF4B4B);
  static const Color locked = Color(0xFF3D4F58);
  static const Color unlocked = primary;

  static const Color streak = Color(0xFFFF9600);
  static const Color gem = Color(0xFF1CB0F6);
  static const Color energy = Color(0xFFFF86D2);
  static const Color accentPurple = Color(0xFFA855F7);
  /// Nền banner “bài mỗi ngày” (vàng đậm, tách khỏi nền tối).
  static const Color bannerYellow = Color(0xFFFFB300);
}
