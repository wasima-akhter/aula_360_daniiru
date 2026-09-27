import 'package:aula360/utils/color/app_colors.dart';
import 'package:flutter/material.dart';

/// 10-Year Flutter Developer Best Practice:
/// Theme structure should always define an explicit [ColorScheme] in addition to
/// individual widget themes. This ensures Material 3 components render with
/// cohesive brand colors automatically.
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: 'Plus Jakarta Sans',

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundColorNew,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontWeight: FontWeight.w800,
      fontSize: 18,
      color: AppColors.darkTextColor,
    ),
    iconTheme: IconThemeData(color: AppColors.black),
  ),

  // Unified button styles with modern figma rounded shapes
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.white,
      minimumSize: const Size(
        140,
        48,
      ), // Industry standard height for readability and tap-targets
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12,
        ), // Matching OutlinedButton corner language
      ),
      textStyle: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
      foregroundColor: AppColors.primaryColor,
      minimumSize: const Size(double.infinity, 50),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Clean unified corner radius
      ),
      textStyle: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryColor,
      textStyle: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),
  ),

  iconTheme: const IconThemeData(
    color: AppColors.grayTertiaryTextColor,
    size: 24,
  ),

  // Modern input field designs with interactive active/focused states
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.backgroundColor,
    iconColor: AppColors.grayTextSecondaryColor,
    prefixIconColor: AppColors.grayTertiaryTextColor,
    suffixIconColor: AppColors.grayTertiaryTextColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

    // Normal border
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.linesDarkColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.linesDarkColor),
    ),

    // Interactive Focused Border: Highlight with primary color for top UX feedback
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
    ),

    // Error borders
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(width: 1.5, color: AppColors.redColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(width: 2, color: AppColors.redColor),
    ),

    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.backgroundsLinesColor),
    ),

    // Figma: Input placeholder → Plus Jakarta Sans, 14px, Regular (400), #9CA3AF
    hintStyle: const TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.hintTextColor,
    ),
    errorStyle: const TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.redColor,
    ),
  ),

  // ─── Figma Typography System ───
  // Extracted from: SomSpot - Business App Figma Design
  //
  // Figma Mapping:
  //   "Create account"  → Plus Jakarta Sans, 24px, Medium (500), #515151
  //   "Full Name" label  → Plus Jakarta Sans, 16px, Medium (500), #334155
  //   Subtitle text      → Plus Jakarta Sans, 16px, Regular (400), #64748B
  //   Tab/chip text      → Plus Jakarta Sans, 14px, Medium (500), #64748B
  //   Placeholder        → Plus Jakarta Sans, 14px, Regular (400), #9CA3AF
  textTheme: const TextTheme(
    // ── Headline: Page-level headings ──
    headlineLarge: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.headingTextColor,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 24, // Figma: "Create account" = 24px
      fontWeight: FontWeight.w500, // Figma: Medium
      color: AppColors.headingTextColor, // Figma: #515151
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: AppColors.headingTextColor,
    ),

    // ── Title: Field labels, section titles ──
    titleLarge: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 18, // Figma: Business name = 18px
      fontWeight: FontWeight.w500, // Figma: Medium
      color: AppColors.darkTextColor, // Figma: #0F172A
    ),
    titleMedium: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 16, // Figma: "Full Name" label = 16px
      fontWeight: FontWeight.w500, // Figma: Medium
      color: AppColors.darkTextColor, // Figma: #334155
    ),
    titleSmall: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.darkTextColor,
    ),

    // ── Body: Content, descriptions, subtitles ──
    bodyLarge: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 16, // Figma: Subtitle text = 16px
      fontWeight: FontWeight.w400, // Figma: Regular
      color: AppColors.subtitleTextColor, // Figma: #64748B
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.subtitleTextColor,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.subtitleTextColor,
    ),

    // ── Label: Tabs, chips, captions, hints ──
    labelLarge: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 14, // Figma: Tab text = 14px
      fontWeight: FontWeight.w500, // Figma: Medium
      color: AppColors.subtitleTextColor, // Figma: #64748B
    ),
    labelMedium: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.hintTextColor, // Figma: #9CA3AF
    ),
    labelSmall: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 10,
      fontWeight: FontWeight.w400,
      color: AppColors.hintTextColor,
    ),
  ),
  colorScheme: const ColorScheme.light(
    primary: AppColors.primaryColor,
    secondary: AppColors.secondPrimaryColor,
    error: AppColors.redColor,
    surface: AppColors.backgroundColor,
    onPrimary: AppColors.white,
    onSecondary: AppColors.white,
    onSurface: AppColors.blackMainTextColor,
  ).copyWith(surface: AppColors.backgroundColorNew),
);
