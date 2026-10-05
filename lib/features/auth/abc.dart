import '../../core/helper/snackbar/api_snackbar.dart';

class AulaValidation {
  static bool required({required String value, required String fieldName}) {
    if (value.trim().isEmpty) {
      ApiSnackbar.show(
        '$fieldName es obligatorio.',
        title: 'Campo Requerido',
        type: SnackbarType.error,
      );
      return false;
    }

    return true;
  }

  static bool email(String value) {
    if (value.trim().isEmpty) {
      ApiSnackbar.show(
        'Por favor, introduce tu correo electrónico.',
        title: 'Correo Requerido',
        type: SnackbarType.error,
      );
      return false;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(value.trim())) {
      ApiSnackbar.show(
        'Por favor, introduce un correo electrónico válido.',
        title: 'Correo Inválido',
        type: SnackbarType.error,
      );
      return false;
    }

    return true;
  }

  static bool phone(String value) {
    if (value.trim().isEmpty) {
      ApiSnackbar.show(
        'Por favor, introduce tu número de teléfono.',
        title: 'Teléfono Requerido',
        type: SnackbarType.error,
      );
      return false;
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 8) {
      ApiSnackbar.show(
        'Por favor, introduce un número de teléfono válido.',
        title: 'Teléfono Inválido',
        type: SnackbarType.error,
      );
      return false;
    }

    return true;
  }

  static bool password(String value) {
    if (value.isEmpty) {
      ApiSnackbar.show(
        'Por favor, introduce tu contraseña.',
        title: 'Contraseña Requerida',
        type: SnackbarType.error,
      );
      return false;
    }

    if (value.length < 8) {
      ApiSnackbar.show(
        'La contraseña debe tener al menos 8 caracteres.',
        title: 'Contraseña Débil',
        type: SnackbarType.error,
      );
      return false;
    }

    return true;
  }
}
