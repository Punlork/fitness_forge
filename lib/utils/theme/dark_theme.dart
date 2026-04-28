import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color_scheme.dart';
import 'styles/base_color_styles.dart';

/*
|--------------------------------------------------------------------------
| Dark Theme
|--------------------------------------------------------------------------
*/

ThemeData darkTheme(BaseColorStyles color) {
  final colorScheme = buildAppColorScheme(
    color,
    brightness: Brightness.dark,
  );

  TextTheme darkTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 57.0,
      fontWeight: FontWeight.w800,
      fontFamily: 'Gilroy',
    ), // For the largest text in your app.
    displayMedium: TextStyle(
      fontSize: 45.0,
      fontWeight: FontWeight.w700,
      fontFamily: 'Gilroy',
    ), // Large text, slightly smaller than displayLarge.
    displaySmall: TextStyle(
      fontSize: 36.0,
      fontWeight: FontWeight.w700,
      fontFamily: 'Gilroy',
    ), // Smaller than displayMedium but larger than headlines.
    headlineLarge: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32.0,
      fontFamily: 'Gilroy',
    ), // Large headlines.
    headlineMedium: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 28.0,
      fontFamily: 'Gilroy',
    ), // Medium headlines.
    headlineSmall: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24.0,
      fontFamily: 'Gilroy',
    ), // Small headlines.
    titleLarge: TextStyle(
      fontSize: 22.0,
      fontWeight: FontWeight.bold,
      fontFamily: 'Gilroy',
    ), // Large titles.
    titleMedium: TextStyle(
      fontSize: 20.0,
      fontFamily: 'Gilroy',
      fontWeight: FontWeight.bold,
    ), // Medium titles.
    titleSmall: TextStyle(
      fontSize: 16.0,
      fontFamily: 'Gilroy',
    ), // Small titles.
    bodyLarge: TextStyle(
      fontSize: 16.0,
      fontFamily: 'Gilroy',
    ), // Large body text.
    bodyMedium: TextStyle(
      fontSize: 14.0,
      fontFamily: 'Gilroy',
    ), // Medium body text.
    bodySmall: TextStyle(
      fontSize: 12.0,
      fontFamily: 'Gilroy',
    ), // Small body text.
    labelLarge: TextStyle(
      fontSize: 14.0,
      fontFamily: 'Gilroy',
    ), // Large labels.
    labelMedium: TextStyle(
      fontSize: 12.0,
      fontFamily: 'Gilroy',
    ), // Medium labels.
    labelSmall: TextStyle(
      fontSize: 10.0,
      fontFamily: 'Gilroy',
    ), // Small labels.
  );

  darkTheme = GoogleFonts.interTextTheme(darkTheme).apply(
    bodyColor: colorScheme.onSurface,
    displayColor: colorScheme.onSurface,
  );

  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    primaryColor: colorScheme.primary,
    appBarTheme: AppBarTheme(
      backgroundColor: color.appBarBackground,
      foregroundColor: color.appBarPrimaryContent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      elevation: 0,
    ),
    textTheme: darkTheme,
    iconTheme: IconThemeData(
      color: colorScheme.onSurface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: color.bottomTabBarBackground,
      selectedItemColor: color.bottomTabBarIconSelected,
      unselectedItemColor: color.bottomTabBarIconUnselected,
      selectedLabelStyle: TextStyle(color: color.bottomTabBarLabelSelected),
      unselectedLabelStyle: TextStyle(color: color.bottomTabBarLabelUnselected),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerLow,
      elevation: 0,
      shadowColor: colorScheme.shadow,
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant,
    ),
  );
}
