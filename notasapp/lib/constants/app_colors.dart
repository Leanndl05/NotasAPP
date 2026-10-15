import 'package:flutter/material.dart';

class NoteColorOption {
  final int value;
  final String name;
  final Color lightColor;
  final Color darkColor;

  const NoteColorOption({
    required this.value,
    required this.name,
    required this.lightColor,
    required this.darkColor,
  });
}

class AppColors {
  static const int defaultColorValue = 0x00000000; // 0 indicates theme default

  static const List<NoteColorOption> noteColors = [
    NoteColorOption(
      value: defaultColorValue,
      name: 'Por defecto',
      lightColor: Color(0xFFFFFFFF),
      darkColor: Color(0xFF1E1E1E),
    ),
    NoteColorOption(
      value: 0xFFFFF176, // Amarillo pastel
      name: 'Amarillo',
      lightColor: Color(0xFFFFF9C4),
      darkColor: Color(0xFF4A4418),
    ),
    NoteColorOption(
      value: 0xFFFF8A80, // Coral / Rojo pastel
      name: 'Coral',
      lightColor: Color(0xFFFFCDD2),
      darkColor: Color(0xFF4E2625),
    ),
    NoteColorOption(
      value: 0xFFFFB74D, // Naranja pastel
      name: 'Naranja',
      lightColor: Color(0xFFFFE0B2),
      darkColor: Color(0xFF4E3218),
    ),
    NoteColorOption(
      value: 0xFFAED581, // Verde claro
      name: 'Verde',
      lightColor: Color(0xFFDCEDC8),
      darkColor: Color(0xFF283B1C),
    ),
    NoteColorOption(
      value: 0xFF80CBC4, // Menta / Turquesa
      name: 'Menta',
      lightColor: Color(0xFFB2DFDB),
      darkColor: Color(0xFF1C3A37),
    ),
    NoteColorOption(
      value: 0xFF90CAF9, // Celeste / Azul pastel
      name: 'Celeste',
      lightColor: Color(0xFFBBDEFB),
      darkColor: Color(0xFF1A334E),
    ),
    NoteColorOption(
      value: 0xFFCE93D8, // Lavanda / Púrpura pastel
      name: 'Lavanda',
      lightColor: Color(0xFFE1BEE7),
      darkColor: Color(0xFF3E2046),
    ),
    NoteColorOption(
      value: 0xFFF48FB1, // Rosa pastel
      name: 'Rosa',
      lightColor: Color(0xFFF8BBD0),
      darkColor: Color(0xFF4E1C2B),
    ),
    NoteColorOption(
      value: 0xFFB0BEC5, // Gris perla
      name: 'Gris',
      lightColor: Color(0xFFECEFF1),
      darkColor: Color(0xFF2E383C),
    ),
  ];

  static Color getBackgroundColor(int colorValue, bool isDark) {
    if (colorValue == defaultColorValue) {
      return isDark ? const Color(0xFF1E222A) : const Color(0xFFFFFFFF);
    }
    final match = noteColors.firstWhere(
      (c) => c.value == colorValue,
      orElse: () => NoteColorOption(
        value: colorValue,
        name: 'Custom',
        lightColor: Color(colorValue),
        darkColor: Color(colorValue).withValues(alpha: 0.3),
      ),
    );
    return isDark ? match.darkColor : match.lightColor;
  }

  static Color getTextColor(Color backgroundColor, bool isDark) {
    // If background is transparent/neutral, use theme text color
    final double luminance = backgroundColor.computeLuminance();
    if (luminance > 0.45) {
      return const Color(0xFF1A1A1A);
    } else {
      return const Color(0xFFF5F5F5);
    }
  }

  static Color getSubtitleColor(Color backgroundColor, bool isDark) {
    final double luminance = backgroundColor.computeLuminance();
    if (luminance > 0.45) {
      return const Color(0xFF555555);
    } else {
      return const Color(0xFFB0B0B0);
    }
  }
}
