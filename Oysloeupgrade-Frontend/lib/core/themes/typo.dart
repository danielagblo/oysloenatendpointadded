import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppTypography {
  AppTypography._();

  static const Color defaultColor = Color(0xFF374957);

  static TextStyle get large => GoogleFonts.inter(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: defaultColor,
      );

  static TextStyle get medium => GoogleFonts.inter(
        fontSize: 22.sp,
        fontWeight: FontWeight.w500,
        height: 1.25,
        color: defaultColor,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: defaultColor,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: defaultColor,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: defaultColor,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 10.sp,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: defaultColor,
      );

  static TextTheme textTheme([Color? color]) {
    final Color effectiveColor = color ?? defaultColor;

    return TextTheme(
      displayLarge: large.copyWith(color: effectiveColor),
      headlineMedium: medium.copyWith(color: effectiveColor),
      bodyLarge: bodyLarge.copyWith(color: effectiveColor),
      bodyMedium: body.copyWith(color: effectiveColor),
      bodySmall: bodySmall.copyWith(color: effectiveColor),
      labelSmall: labelSmall.copyWith(color: effectiveColor),
    );
  }
}