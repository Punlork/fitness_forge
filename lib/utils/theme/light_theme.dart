import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color_scheme.dart';
import 'styles/base_color_styles.dart';

/*
|--------------------------------------------------------------------------
| Light Theme
|
| Theme Config - config/theme.dart
|--------------------------------------------------------------------------
*/

ThemeData lightTheme(BaseColorStyles color) {
  final colorScheme = buildAppColorScheme(
    color,
    brightness: Brightness.light,
  );

  TextTheme lightTheme = TextTheme(
    displayLarge: const TextStyle(
      fontSize: 57.0,
      fontWeight: FontWeight.w800,
      fontFamily: 'Gilroy',
    ), // For the largest text in your app.
    displayMedium: const TextStyle(
      fontSize: 45.0,
      fontWeight: FontWeight.w700,
      fontFamily: 'Gilroy',
    ), // Large text, slightly smaller than displayLarge.
    displaySmall: const TextStyle(
      fontSize: 36.0,
      fontWeight: FontWeight.w700,
      fontFamily: 'Gilroy',
    ), // Smaller than displayMedium but larger than headlines.
    headlineLarge: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32.0,
      fontFamily: 'Gilroy',
    ), // Large headlines.
    headlineMedium: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 28.0,
      fontFamily: 'Gilroy',
    ), // Medium headlines.
    headlineSmall: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24.0,
      fontFamily: 'Gilroy',
    ), // Small headlines.
    titleLarge: const TextStyle(
      fontSize: 22.0,
      fontWeight: FontWeight.bold,
      fontFamily: 'Gilroy',
    ), // Large titles.
    titleMedium: TextStyle(
      fontSize: 20.0,
      fontFamily: 'Gilroy',
      fontWeight: FontWeight.bold,
    ), // Medium titles.
    titleSmall: const TextStyle(
      fontSize: 18.0,
      fontFamily: 'Gilroy',
    ), // Small titles.
    bodyLarge: const TextStyle(
      fontSize: 16.0,
      fontFamily: 'Gilroy',
    ), // Larger body text.
    bodyMedium: const TextStyle(
      fontSize: 14.0,
      fontFamily: 'Gilroy',
    ), // Standard body text.
    bodySmall: const TextStyle(
      fontSize: 12.0,
      fontFamily: 'Gilroy',
    ), // Small body text.
    labelLarge: const TextStyle(
      fontSize: 14.0,
      fontFamily: 'Gilroy',
    ), // Larger labels.
    labelMedium: const TextStyle(
      fontSize: 12.0,
      fontFamily: 'Gilroy',
    ), // Medium labels.
    labelSmall: const TextStyle(
      fontSize: 11.0,
      fontFamily: 'Gilroy',
    ), // Small labels.
  );

  lightTheme = GoogleFonts.interTextTheme(lightTheme).apply(
    bodyColor: colorScheme.onSurface,
    displayColor: colorScheme.onSurface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    primaryColor: colorScheme.primary,
    primaryColorLight: colorScheme.primaryContainer,
    focusColor: colorScheme.primary,
    hintColor: colorScheme.onSurfaceVariant,
    dividerTheme: DividerThemeData(color: colorScheme.outlineVariant),
    appBarTheme: AppBarTheme(
      backgroundColor: color.appBarBackground,
      titleTextStyle:
          lightTheme.titleLarge!.copyWith(color: color.appBarPrimaryContent),
      iconTheme: IconThemeData(color: color.appBarPrimaryContent),
      elevation: 1.0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: color.buttonPrimaryContent,
      colorScheme: colorScheme,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: color.bottomTabBarBackground,
      unselectedIconTheme:
          IconThemeData(color: color.bottomTabBarIconUnselected),
      selectedIconTheme: IconThemeData(color: color.bottomTabBarIconSelected),
      unselectedLabelStyle: TextStyle(color: color.bottomTabBarLabelUnselected),
      selectedLabelStyle: TextStyle(color: color.bottomTabBarLabelSelected),
      selectedItemColor: color.bottomTabBarLabelSelected,
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerLow,
      elevation: 0,
      shadowColor: colorScheme.shadow,
    ),
    textTheme: lightTheme,
  );
}

/*
|--------------------------------------------------------------------------
| Light Text Theme
|--------------------------------------------------------------------------
*/

// TextTheme _textTheme(BaseColorStyles colors) {
//   Color primaryContent = colors.primaryContent;
//   TextTheme textTheme = const TextTheme().apply(displayColor: primaryContent);
//   return textTheme.copyWith(
//       labelLarge: TextStyle(color: primaryContent.withOpacity(0.8)));
// }
