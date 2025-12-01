import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF74FFA7);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grayF9 = Color(0xFFF9F9F9);
  static const Color grayE4 = Color.fromARGB(255, 240, 240, 240);
  static const Color blueGray374957 = Color(0xFF374957);
  static const Color blueGray263238 = Color(0xFF263238);
  static const Color grayD9 = Color(0xFFD9D9D9);
  static const Color grayBFBF = Color(0xFFBFBFBF);
  static const Color gray222222 = Color(0xFF222222);
  static const Color gray8B959E = Color(0xFF8B959E);
  static const Color greenDEFEED = Color(0xFFDEFEED);
  static const Color redFF6B6B = Color(0xFFFF6B6B);

  static const Color black81Opacity = Color(0xCF000000);
  static const Color gray59Opacity = Color(0x97000000);
  static const Color black72Opacity = Color(0xB8000000);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, blueGray374957, primary, redFF6B6B],
    stops: [0.0, 0.24, 0.5, 0.76],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    tileMode: TileMode.clamp,
  );
}

ThemeData buildAppTheme(Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;

  final Color primaryColor = AppColors.primary;
  final Color scaffoldBg = isDark ? AppColors.blueGray263238 : AppColors.white;
  final Color cardBg = isDark ? AppColors.blueGray374957 : AppColors.grayF9;
  final Color divider = AppColors.grayD9;
  final Color textPrimary = isDark ? AppColors.white : AppColors.blueGray374957;
  final Color textSecondary = AppColors.gray8B959E;

  final ColorScheme colorScheme = ColorScheme(
    brightness: brightness,
    primary: primaryColor,
    onPrimary: AppColors.gray222222,
    secondary: AppColors.blueGray374957,
    onSecondary: AppColors.white,
    error: const Color(0xFFB00020),
    onError: AppColors.white,
    surface: cardBg,
    onSurface: textPrimary,
  );

  final TextTheme textTheme = AppTypography.textTheme(textPrimary);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scaffoldBg,
    textTheme: textTheme,
    cupertinoOverrideTheme: CupertinoThemeData(
      primaryColor: AppColors.blueGray374957,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.blueGray374957,
      selectionColor: AppColors.blueGray374957.withValues(alpha: 0.25),
      selectionHandleColor: AppColors.blueGray374957,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scaffoldBg,
      foregroundColor: textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.headlineMedium,
    ),
    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 0,
      margin: EdgeInsets.all(3.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: divider),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? AppColors.blueGray374957 : AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.transparent, width: 1.5),
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
    ),
    iconTheme: IconThemeData(color: textSecondary, size: 20.sp),
    dividerTheme: DividerThemeData(color: divider, thickness: 1),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: AppColors.gray222222,
      elevation: 0,
    ),
  );
}
