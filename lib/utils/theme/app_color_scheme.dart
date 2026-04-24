import 'package:flutter/material.dart';

import 'styles/base_color_styles.dart';

Color _opaqueBlend(Color base, Color target, double amount) {
  return Color.lerp(base, target, amount)!.withAlpha(255);
}

ColorScheme buildAppColorScheme(
  BaseColorStyles color, {
  required Brightness brightness,
}) {
  final seedScheme = ColorScheme.fromSeed(
    seedColor: color.primaryAccent,
    brightness: brightness,
  );

  final surface = color.surfaceBackground;
  final onSurface = color.surfaceContent;

  return seedScheme.copyWith(
    brightness: brightness,
    primary: color.primaryAccent,
    onPrimary: color.buttonPrimaryContent,
    primaryContainer: color.primaryAccent.withValues(alpha: 0.20),
    onPrimaryContainer: color.primaryContent,
    secondary: color.bottomTabBarIconSelected,
    onSecondary: color.primaryContent,
    secondaryContainer: _opaqueBlend(surface, onSurface, 0.08),
    onSecondaryContainer: color.surfaceContent,
    tertiary: color.bottomTabBarLabelSelected,
    onTertiary: color.primaryContent,
    tertiaryContainer: _opaqueBlend(surface, onSurface, 0.12),
    onTertiaryContainer: color.surfaceContent,
    error: color.inputErrorLabelColor,
    onError: brightness == Brightness.dark ? Colors.black : Colors.white,
    errorContainer: color.inputErrorLabelColor.withValues(alpha: 0.20),
    onErrorContainer: color.inputErrorLabelColor,
    surface: color.surfaceBackground,
    onSurface: color.surfaceContent,
    surfaceContainerLowest: color.background,
    surfaceContainerLow: _opaqueBlend(surface, onSurface, 0.04),
    surfaceContainer: _opaqueBlend(surface, onSurface, 0.08),
    surfaceContainerHigh: _opaqueBlend(surface, onSurface, 0.12),
    surfaceContainerHighest: _opaqueBlend(surface, onSurface, 0.16),
    onSurfaceVariant: color.labelTextColor,
    outline: color.textfieldBorderColor,
    outlineVariant: color.textfieldBorderColor.withValues(alpha: 0.65),
    shadow: Colors.black.withValues(alpha: 0.20),
    scrim: Colors.black.withValues(alpha: 0.40),
    inverseSurface: color.primaryContent,
    onInverseSurface: color.background,
    inversePrimary: color.primaryAccent.withValues(alpha: 0.80),
  );
}
