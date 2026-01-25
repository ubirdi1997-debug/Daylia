import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF5F7FB);
  static const Color lightSurface = Colors.white;
  static const Color lightPrimary = Color(0xFF5B6CFF);
  static const Color lightAccent = Color(0xFF22D3EE);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkPrimary = Color(0xFF818CF8);
  static const Color darkAccent = Color(0xFF2DD4BF);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Semantic Colors
  static const Color successLight = Color(0xFF10B981);
  static const Color successDark = Color(0xFF6EE7B7);
  static const Color warningLight = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFFCD34D);
  static const Color errorLight = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFFCA5A5);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF5B6CFF),
    Color(0xFF818CF8),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF22D3EE),
    Color(0xFF2DD4BF),
  ];
}
