import 'package:flutter/services.dart';

/// Centralized input formatters for special input fields across Aula 360.
class AppInputFormatters {
  const AppInputFormatters._();

  /// Formatter for email fields: forbids whitespace and converts characters to lowercase.
  static final List<TextInputFormatter> email = [
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
    _LowerCaseTextFormatter(),
  ];

  /// Formatter for phone fields: allows digits, +, -, whitespace, and parentheses.
  static final List<TextInputFormatter> phone = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-()]')),
  ];

  /// Formatter for strict numeric fields (OTP, PINs, IDs).
  static final List<TextInputFormatter> digitsOnly = [
    FilteringTextInputFormatter.digitsOnly,
  ];

  /// Formatter for names: allows letters (including accented Spanish/multilingual characters), spaces, hyphens, and apostrophes.
  static final List<TextInputFormatter> name = [
    FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚñÑüÜàèìòùÀÈÌÒÙäëïöüÄËÏÖÜ\s'\-]"),
    ),
  ];

  /// Formatter for password fields: prevents accidental whitespace (spaces, tabs, newlines).
  static final List<TextInputFormatter> password = [
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
  ];
}

class _LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toLowerCase());
  }
}
