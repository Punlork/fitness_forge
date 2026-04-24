import 'package:flutter/material.dart';
import 'base_color_styles.dart';

/*
|--------------------------------------------------------------------------
| Light Theme Colors
|--------------------------------------------------------------------------
*/

class LightThemeColors implements BaseColorStyles {
  // general
  @override
  Color get background => const Color(0xFFFFFFFF);

  @override
  Color get primaryContent => const Color(0xFF111827);
  @override
  Color get primaryAccent => const Color(0xFF10B981);

  @override
  Color get surfaceBackground => const Color(0xFFF8FAFC);
  @override
  Color get surfaceContent => const Color(0xFF111827);

  // app bar
  @override
  Color get appBarBackground => const Color(0xFF10B981);
  @override
  Color get appBarPrimaryContent => Colors.white;

  // buttons
  @override
  Color get buttonBackground => const Color(0xFF10B981);
  @override
  Color get buttonPrimaryContent => Colors.white;

  // bottom tab bar
  @override
  Color get bottomTabBarBackground => const Color(0xFFFFFFFF);

  // bottom tab bar - icons
  @override
  Color get bottomTabBarIconSelected => const Color(0xFF10B981);
  @override
  Color get bottomTabBarIconUnselected => const Color(0xFF64748B);

  // bottom tab bar - label
  @override
  Color get bottomTabBarLabelUnselected => const Color(0xFF64748B);
  @override
  Color get bottomTabBarLabelSelected => const Color(0xFF111827);

  // InputDecorator
  @override
  Color get inputFillColor => const Color(0xFFF1F5F9);
  @override
  Color get inputErrorLabelColor => const Color(0xFFDC2626);
  @override
  Color get inputFocusedLabelColor => const Color(0xFF10B981);
  @override
  Color get inputDefaultLabelColor =>
      const Color(0xFF000000); // This matches the primaryContent color.
  @override
  Color get selectedValuesTextColor =>
      const Color(0xFF000000); // Black for light theme.
  @override
  Color get textfieldBorderColor => const Color(0xFFCBD5E1);
  @override
  Color get labelTextColor => const Color(0xFF64748B);
}
