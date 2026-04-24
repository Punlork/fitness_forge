import 'package:flutter/material.dart';
import 'base_color_styles.dart';

/*
|--------------------------------------------------------------------------
| Dark Theme Colors
|--------------------------------------------------------------------------
*/

class DarkThemeColors implements BaseColorStyles {
  // general
  @override
  Color get background => const Color(0xFF020617);

  @override
  Color get primaryContent => const Color(0xFFFFFFFF);
  @override
  Color get primaryAccent => const Color(0xFF10B981);

  @override
  Color get surfaceBackground => const Color(0xFF0B1220);
  @override
  Color get surfaceContent => Colors.white;

  // app bar
  @override
  Color get appBarBackground => const Color(0xFF0B1220);
  @override
  Color get appBarPrimaryContent => Colors.white;

  // buttons
  @override
  Color get buttonBackground => const Color(0xFF10B981);
  @override
  Color get buttonPrimaryContent => const Color(0xFF052E2B);

  // bottom tab bar
  @override
  Color get bottomTabBarBackground => const Color(0xFF0B1220);

  // bottom tab bar - icons
  @override
  Color get bottomTabBarIconSelected => const Color(0xFF10B981);
  @override
  Color get bottomTabBarIconUnselected => const Color(0xFF94A3B8);

  // bottom tab bar - label
  @override
  Color get bottomTabBarLabelUnselected => const Color(0xFF94A3B8);
  @override
  Color get bottomTabBarLabelSelected => Colors.white;

  // Input Decorator Colors
  @override
  Color get inputFillColor => const Color(0xFF111827);
  @override
  Color get inputErrorLabelColor => const Color(0xFFCF6679);
  @override
  Color get inputFocusedLabelColor => const Color(0xFF10B981);
  @override
  Color get inputDefaultLabelColor => Colors.white54;
  @override
  Color get selectedValuesTextColor => Colors.white;
  @override
  Color get textfieldBorderColor => const Color(0xFF334155);
  @override
  Color get labelTextColor => const Color(0xFF94A3B8);
}
