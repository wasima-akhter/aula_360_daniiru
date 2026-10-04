import 'package:aula360/utils/color/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../router/routes.dart';

/// One place that knows how to build a themed style.
class _TxtVariant {
  const _TxtVariant(this._pick);

  final TextStyle? Function(TextTheme theme) _pick;

  TextStyle call({
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    List<FontVariation>? fontVariations,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
    TextLeadingDistribution? leadingDistribution,
  }) {
    final navContext = AppRouter.navigatorKey.currentContext;
    final textTheme = navContext != null
        ? Theme.of(navContext).textTheme
        : ThemeData.fallback().textTheme; // no crash before first frame

    return (_pick(textTheme) ?? const TextStyle()).copyWith(
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize?.sp,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      fontVariations: fontVariations,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      overflow: overflow,
      leadingDistribution: leadingDistribution,
    );
  }
}

class TxtStyle {
  const TxtStyle._();

  // Headlines
  static final headlineLarge = _TxtVariant((t) => t.headlineLarge);
  static final headlineMedium = _TxtVariant((t) => t.headlineMedium);
  static final headlineSmall = _TxtVariant((t) => t.headlineSmall);

  // Titles
  static final titleLarge = _TxtVariant((t) => t.titleLarge);
  static final titleMedium = _TxtVariant((t) => t.titleMedium);
  static final titleSmall = _TxtVariant((t) => t.titleSmall);

  // Body
  static final bodyLarge = _TxtVariant((t) => t.bodyLarge);
  static final bodyMedium = _TxtVariant((t) => t.bodyMedium);
  static final bodySmall = _TxtVariant((t) => t.bodySmall);

  // Labels
  static final labelLarge = _TxtVariant((t) => t.labelLarge);
  static final labelMedium = _TxtVariant((t) => t.labelMedium);
  static final labelSmall = _TxtVariant((t) => t.labelSmall);
}

extension ThemeTextStyles on BuildContext {
  TextTheme get style => Theme.of(this).textTheme;
}

///

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  fontFamily: 'Plus Jakarta Sans',

  scaffoldBackgroundColor: AppColors.background,

  // ─────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.text,
    ),
    iconTheme: IconThemeData(color: AppColors.text, size: 24),
  ),

  // ─────────────────────────────────────────────
  // ELEVATED BUTTON
  // ─────────────────────────────────────────────
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      minimumSize: const Size(140, 48),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),

  // ─────────────────────────────────────────────
  // OUTLINED BUTTON
  // ─────────────────────────────────────────────
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      minimumSize: const Size(double.infinity, 48),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      side: const BorderSide(color: AppColors.primary, width: 1.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),

  // ─────────────────────────────────────────────
  // TEXT BUTTON
  // ─────────────────────────────────────────────
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      textStyle: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),

  // ─────────────────────────────────────────────
  // ICONS
  // ─────────────────────────────────────────────
  iconTheme: const IconThemeData(color: AppColors.slateIconColor, size: 24),

  // ─────────────────────────────────────────────
  // INPUT FIELDS
  // ─────────────────────────────────────────────
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.background,

    iconColor: AppColors.secondaryText,
    prefixIconColor: AppColors.secondaryText,
    suffixIconColor: AppColors.secondaryText,

    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),

    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.backgroundsLinesColor),
    ),

    hintStyle: const TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 16.5,
      fontWeight: FontWeight.w500,
      color: AppColors.hintTextColor,
    ),

    labelStyle: const TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 16.5,
      fontWeight: FontWeight.w500,
      color: AppColors.labelTextColor,
    ),

    floatingLabelStyle: const TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 16.5,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
    ),

    errorStyle: const TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 14.5,
      fontWeight: FontWeight.w500,
      color: AppColors.error,
    ),
  ),

  // ─────────────────────────────────────────────
  // TYPOGRAPHY
  // ─────────────────────────────────────────────
  textTheme: const TextTheme(
    // HEADLINES
    headlineLarge: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: AppColors.text,
      height: 1.2,
    ),

    headlineMedium: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: AppColors.text,
      height: 1.25,
    ),

    headlineSmall: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.text,
      height: 1.3,
    ),

    // TITLES
    titleLarge: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.text,
      height: 1.3,
    ),

    titleMedium: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 19,
      fontWeight: FontWeight.w600,
      color: AppColors.text,
      height: 1.35,
    ),

    titleSmall: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.text,
      height: 1.35,
    ),

    // BODY
    bodyLarge: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 19,
      fontWeight: FontWeight.w500,
      color: AppColors.secondaryText,
      height: 1.5,
    ),

    bodyMedium: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 16.5,
      fontWeight: FontWeight.w500,
      color: AppColors.secondaryText,
      height: 1.5,
    ),

    bodySmall: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 14.5,
      fontWeight: FontWeight.w500,
      color: AppColors.secondaryText,
      height: 1.45,
    ),

    // LABELS
    labelLarge: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.labelTextColor,
      height: 1.3,
    ),

    labelMedium: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 14.5,
      fontWeight: FontWeight.w500,
      color: AppColors.subtitleTextColor,
      height: 1.3,
    ),

    labelSmall: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.hintTextColor,
      height: 1.3,
    ),
  ),

  // ─────────────────────────────────────────────
  // COLOR SCHEME
  // ─────────────────────────────────────────────
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.white,

    secondary: AppColors.blueAccentColor,
    onSecondary: AppColors.white,

    error: AppColors.error,
    onError: AppColors.white,

    surface: AppColors.background,
    onSurface: AppColors.text,

    outline: AppColors.border,
  ),
);
