import 'package:flutter/material.dart';

/// Cellit brand palette and custom colors that may differ from [AppTheme] colorSchemes
class AppColors {
  // Prevents instantiation and extension
  AppColors._();

  // Brand palette
  static const Color primary = Color(0xFFFB8500);
  static const Color amber = Color(0xFFFFB703);
  static const Color deepNavy = Color(0xFF023047);
  static const Color teal = Color(0xFF219EBC);
  static const Color skyBlue = Color(0xFF8ECAE6);

  // Neutral & semantic colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF212121);
  static const Color green = Color(0xFF48C54A);
  static const Color red = Color(0xFFF4462C);
  static const Color yellow = Color(0xFFF9AA00);
  static const Color blue = Color(0xFF3886E3);
}
