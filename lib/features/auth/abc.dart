import '../../core/helper/snackbar/api_snackbar.dart';

class AulaValidation {
  static bool required({required String value, required String fieldName}) {
    if (value.trim().isEmpty) {
      ApiSnackbar.show(
        '$fieldName is required.',
        title: 'Missing $fieldName',
        type: SnackbarType.error,
      );
      return false;
    }

    return true;
  }

  static bool email(String value) {
    if (value.trim().isEmpty) {
      ApiSnackbar.show(
        'Please enter your email address.',
        title: 'Email Required',
        type: SnackbarType.error,
      );
      return false;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(value.trim())) {
      ApiSnackbar.show(
        'Please enter a valid email address.',
        title: 'Invalid Email',
        type: SnackbarType.error,
      );
      return false;
    }

    return true;
  }

  static bool phone(String value) {
    if (value.trim().isEmpty) {
      ApiSnackbar.show(
        'Please enter your mobile number.',
        title: 'Mobile Number Required',
        type: SnackbarType.error,
      );
      return false;
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 8) {
      ApiSnackbar.show(
        'Please enter a valid mobile number.',
        title: 'Invalid Mobile Number',
        type: SnackbarType.error,
      );
      return false;
    }

    return true;
  }

  static bool password(String value) {
    if (value.isEmpty) {
      ApiSnackbar.show(
        'Please enter your password.',
        title: 'Password Required',
        type: SnackbarType.error,
      );
      return false;
    }

    if (value.length < 8) {
      ApiSnackbar.show(
        'Password must contain at least 8 characters.',
        title: 'Weak Password',
        type: SnackbarType.error,
      );
      return false;
    }

    return true;
  }
}
