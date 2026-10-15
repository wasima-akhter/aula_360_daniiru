import '../enums/backend_enums.dart';
import '../errors/app_error_resolver.dart';
import '../helper/snackbar/api_snackbar.dart';

class AulaValidation {
  /// Global active language code tracked across the app (defaults to 'en').
  static String activeLanguageCode = 'en';

  static bool _isSpanish(String? languageCode) {
    final code = languageCode ?? activeLanguageCode;
    return code.toLowerCase().startsWith('es');
  }

  /// Sanitizes phone numbers by stripping formatting characters (spaces, dashes, parentheses)
  /// while preserving optional leading '+' sign.
  static String sanitizePhone(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    final hasPlus = trimmed.startsWith('+');
    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    return hasPlus ? '+$digitsOnly' : digitsOnly;
  }

  static bool required({
    required String value,
    required String fieldName,
    String? languageCode,
  }) {
    if (value.trim().isEmpty) {
      final isEs = _isSpanish(languageCode);
      ApiSnackbar.show(
        isEs ? '$fieldName es obligatorio.' : '$fieldName is required.',
        title: isEs ? 'Campo Requerido' : 'Field Required',
        type: SnackbarType.error,
        languageCode: languageCode,
      );
      return false;
    }

    return true;
  }

  static bool email(String value, {String? languageCode}) {
    final isEs = _isSpanish(languageCode);
    if (value.trim().isEmpty) {
      ApiSnackbar.show(
        isEs
            ? 'Por favor, introduce tu correo electrónico.'
            : 'Please enter your email address.',
        title: isEs ? 'Correo Requerido' : 'Email Required',
        type: SnackbarType.error,
        languageCode: languageCode,
      );
      return false;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(value.trim())) {
      ApiSnackbar.show(
        isEs
            ? 'Por favor, introduce un correo electrónico válido.'
            : 'Please enter a valid email address.',
        title: isEs ? 'Correo Inválido' : 'Invalid Email',
        type: SnackbarType.error,
        languageCode: languageCode,
      );
      return false;
    }

    return true;
  }

  static bool phone(String value, {String? languageCode}) {
    final isEs = _isSpanish(languageCode);
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      ApiSnackbar.show(
        isEs
            ? 'Por favor, introduce tu número de teléfono.'
            : 'Please enter your phone number.',
        title: isEs ? 'Teléfono Requerido' : 'Phone Required',
        type: SnackbarType.error,
        languageCode: languageCode,
      );
      return false;
    }

    // Check allowed characters: digits, space, +, -, (, )
    final allowedChars = RegExp(r'^[0-9+\s\-()]+$');
    if (!allowedChars.hasMatch(trimmed)) {
      ApiSnackbar.show(
        isEs
            ? 'Número de teléfono no válido'
            : 'Invalid phone number',
        title: isEs ? 'Teléfono Inválido' : 'Invalid Phone',
        type: SnackbarType.error,
        languageCode: languageCode,
      );
      return false;
    }

    final sanitized = sanitizePhone(trimmed);
    final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');

    if (!phoneRegex.hasMatch(sanitized)) {
      ApiSnackbar.show(
        isEs
            ? 'Número de teléfono no válido (debe tener entre 8 y 15 dígitos)'
            : 'Invalid phone number (must be 8-15 digits)',
        title: isEs ? 'Teléfono Inválido' : 'Invalid Phone',
        type: SnackbarType.error,
        languageCode: languageCode,
      );
      return false;
    }

    return true;
  }

  /// Evaluates password strength and returns list of missing criteria messages.
  static List<String> getMissingPasswordRequirements(
    String value, {
    String? languageCode,
  }) {
    final isEs = _isSpanish(languageCode);
    final errors = <String>[];

    if (value.length < 8) {
      errors.add(
        isEs
            ? 'La contraseña debe tener al menos 8 caracteres'
            : 'Password must be at least 8 characters',
      );
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      errors.add(
        isEs
            ? 'La contraseña debe contener al menos una letra mayúscula'
            : 'Password must contain at least one uppercase letter',
      );
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      errors.add(
        isEs
            ? 'La contraseña debe contener al menos una letra minúscula'
            : 'Password must contain at least one lowercase letter',
      );
    }
    if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(value)) {
      errors.add(
        isEs
            ? 'La contraseña debe contener al menos un carácter especial'
            : 'Password must contain at least one special character',
      );
    }

    return errors;
  }

  static bool password(String value, {String? languageCode}) {
    final isEs = _isSpanish(languageCode);
    if (value.isEmpty) {
      ApiSnackbar.show(
        isEs
            ? 'Por favor, introduce tu contraseña.'
            : 'Please enter your password.',
        title: isEs ? 'Contraseña Requerida' : 'Password Required',
        type: SnackbarType.error,
        languageCode: languageCode,
      );
      return false;
    }

    final missing =
        getMissingPasswordRequirements(value, languageCode: languageCode);
    if (missing.isNotEmpty) {
      final title = isEs ? 'Error de validación' : 'Validation Error';
      final directive = isEs
          ? (missing.length > 1
              ? 'Por favor cumple con todos los requisitos e intenta de nuevo.'
              : 'Por favor cumple con el requisito e intenta de nuevo.')
          : (missing.length > 1
              ? 'Please fulfill all requirements and try again.'
              : 'Please fulfill the requirement and try again.');
      final message = missing.length == 1
          ? missing.first
          : missing.map((e) => '• $e').join('\n');

      ApiSnackbar.showUserMessage(
        UserFriendlyMessage(
          title: title,
          message: message,
          directive: directive,
          errorType: ApiErrorType.validationError,
          errors: missing,
        ),
      );
      return false;
    }

    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Inline & Field Validators (return localized error message or null)
  // ─────────────────────────────────────────────────────────────────────────

  /// Validates that a required field is not empty.
  static String? validateRequired(
    String? value, {
    required String fieldName,
    String? languageCode,
  }) {
    final isEs = _isSpanish(languageCode);
    if (value == null || value.trim().isEmpty) {
      return isEs ? '$fieldName es obligatorio.' : '$fieldName is required.';
    }
    return null;
  }

  /// Validates email format and non-emptiness.
  static String? validateEmail(
    String? value, {
    String? languageCode,
  }) {
    final isEs = _isSpanish(languageCode);
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return isEs
          ? 'Por favor, introduce tu correo electrónico.'
          : 'Please enter your email address.';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(trimmed)) {
      return isEs
          ? 'Por favor, introduce un correo electrónico válido.'
          : 'Please enter a valid email address.';
    }

    return null;
  }

  /// Validates phone number format and digit count.
  static String? validatePhone(
    String? value, {
    String? languageCode,
  }) {
    final isEs = _isSpanish(languageCode);
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return isEs
          ? 'Por favor, introduce tu número de teléfono.'
          : 'Please enter your phone number.';
    }

    final allowedChars = RegExp(r'^[0-9+\s\-()]+$');
    if (!allowedChars.hasMatch(trimmed)) {
      return isEs ? 'Número de teléfono no válido' : 'Invalid phone number';
    }

    final sanitized = sanitizePhone(trimmed);
    final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
    if (!phoneRegex.hasMatch(sanitized)) {
      return isEs
          ? 'Número de teléfono no válido (debe tener entre 8 y 15 dígitos)'
          : 'Invalid phone number (must be 8-15 digits)';
    }

    return null;
  }

  /// Validates password strength and returns first missing requirement message.
  static String? validatePassword(
    String? value, {
    String? languageCode,
  }) {
    final isEs = _isSpanish(languageCode);
    final text = value ?? '';
    if (text.isEmpty) {
      return isEs
          ? 'Por favor, introduce tu contraseña.'
          : 'Please enter your password.';
    }

    final missing = getMissingPasswordRequirements(
      text,
      languageCode: languageCode,
    );
    if (missing.isNotEmpty) {
      return missing.first;
    }

    return null;
  }
}
