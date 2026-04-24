import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppHeaderLevel {
  page,
  section,
  subsection,
}

class AppHeaderText extends StatelessWidget {
  final String text;
  final AppHeaderLevel level;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;
  final double? letterSpacing;
  final double? height;

  const AppHeaderText(
    this.text, {
    this.level = AppHeaderLevel.section,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
    this.letterSpacing,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final defaultStyle = switch (level) {
      AppHeaderLevel.page => textTheme.titleLarge,
      AppHeaderLevel.section => textTheme.titleMedium,
      AppHeaderLevel.subsection => textTheme.titleSmall,
    };

    final defaultWeight = switch (level) {
      AppHeaderLevel.page => FontWeight.w800,
      AppHeaderLevel.section => FontWeight.w700,
      AppHeaderLevel.subsection => FontWeight.w700,
    };

    final defaultSpacing = switch (level) {
      AppHeaderLevel.page => -0.25,
      AppHeaderLevel.section => -0.15,
      AppHeaderLevel.subsection => -0.1,
    };

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: GoogleFonts.manrope(
        textStyle: defaultStyle,
        color: color,
        fontWeight: fontWeight ?? defaultWeight,
        letterSpacing: letterSpacing ?? defaultSpacing,
        height: height,
      ),
    );
  }
}
