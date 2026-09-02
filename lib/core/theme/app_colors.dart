import 'package:flutter/material.dart';

/// "Vibrant EdTech" design-system colors for PreparationHotspot -- an
/// energetic indigo/emerald palette meant to feel confident and a little
/// gamified, without tipping into a toy-like look.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF4F46E5);
  static const primaryDark = Color(0xFF3730A3);
  static const primaryLight = Color(0xFFEEF2FF);
  static const secondary = Color(0xFF10B981);
  static const accentAmber = Color(0xFFF59E0B);

  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);

  static const strong = Color(0xFF16A34A);
  static const strongBg = Color(0xFFECFDF5);
  static const average = Color(0xFFF59E0B);
  static const averageBg = Color(0xFFFFFBEB);
  static const weak = Color(0xFFEF4444);
  static const weakBg = Color(0xFFFEF2F2);
  static const insufficientData = Color(0xFF94A3B8);

  static const border = Color(0xFFE2E8F0);
  static const error = Color(0xFFEF4444);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
  );
}
