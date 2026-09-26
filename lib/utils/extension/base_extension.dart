import 'package:aula360/core/router/route_path.dart';
import 'package:flutter/material.dart';

extension BasePathExtensions on String {
  String get addBasePath {
    return RoutePath.basePath + this;
  }
}

extension ContextExtensions on BuildContext {
  // ----------------- MEDIA QUERY -----------------
  double get screenHeight => MediaQuery.of(this).size.height;
  double get screenWidth => MediaQuery.of(this).size.width;

  // ----------------- TEXT THEME -----------------
  TextTheme get textTheme => Theme.of(this).textTheme;

  TextStyle get headlineLarge => textTheme.headlineLarge!;
  TextStyle get headlineMedium => textTheme.headlineMedium!;
  TextStyle get headlineSmall => textTheme.headlineSmall!;
  TextStyle get titleLarge => textTheme.titleLarge!;
  TextStyle get titleMedium => textTheme.titleMedium!;
  TextStyle get titleSmall => textTheme.titleSmall!;
  TextStyle get bodyLarge => textTheme.bodyLarge!;
  TextStyle get bodyMedium => textTheme.bodyMedium!;
  TextStyle get bodySmall => textTheme.bodySmall!;
  TextStyle get labelLarge => textTheme.labelLarge!;
  TextStyle get labelMedium => textTheme.labelMedium!;
  TextStyle get labelSmall => textTheme.labelSmall!;

  // ----------------- BUTTON STYLE -----------------
  ButtonStyle get buttonStyle =>
      Theme.of(this).elevatedButtonTheme.style ?? ElevatedButton.styleFrom();

  ButtonStyle get outlinedButtonStyle =>
      Theme.of(this).outlinedButtonTheme.style ?? OutlinedButton.styleFrom();
}
