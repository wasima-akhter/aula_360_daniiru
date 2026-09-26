import 'package:flutter/cupertino.dart';

import '../../../utils/app_strings/app_strings.dart';

class TextFieldValidator {
  static String? Function(String?) required({required String errorText}) {
    return (value) {
      final trimmed = value?.trim() ?? '';

      if (trimmed.isEmpty) {
        return errorText;
      }

      return null;
    };
  }

  static String? Function(String?) email() {
    return (value) {
      final trimmed = value?.trim() ?? '';

      if (trimmed.isEmpty) {
        return AppStrings.emailRequired;
      }

      final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

      if (!emailRegex.hasMatch(trimmed)) {
        return AppStrings.validEmailAddress;
      }

      return null;
    };
  }

  static String? Function(String?) password() {
    return (value) {
      final trimmed = value?.trim() ?? '';

      if (trimmed.isEmpty) {
        return AppStrings.passwordRequired;
      }

      if (trimmed.length < 8) {
        return AppStrings.passwordMin8;
      }

      if (!RegExp(r'[A-Z]').hasMatch(trimmed)) {
        return AppStrings.uppercaseRequired;
      }

      if (!RegExp(r'[0-9]').hasMatch(trimmed)) {
        return AppStrings.numberRequired;
      }

      return null;
    };
  }

  static String? Function(String?) confirmPassword(
    TextEditingController originalController,
  ) {
    return (value) {
      final trimmed = value?.trim() ?? '';
      final originalPassword = originalController.text.trim();

      if (trimmed.isEmpty) {
        return AppStrings.confirmPasswordRequired;
      }

      if (originalPassword.isEmpty) {
        return AppStrings.enterPasswordFirst;
      }

      if (trimmed != originalPassword) {
        return AppStrings.passwordsDoNotMatch;
      }

      return null;
    };
  }

  static String? Function(String?) otp() {
    return (value) {
      final trimmed = value?.trim() ?? '';

      if (trimmed.isEmpty) {
        return AppStrings.otpRequired;
      }

      if (trimmed.length != 6) {
        return AppStrings.otpMustBe6Digits;
      }

      if (!RegExp(r'^[0-9]{6}$').hasMatch(trimmed)) {
        return AppStrings.otpNumbersOnly;
      }

      return null;
    };
  }

  static String? Function(String?) requiredField({
    String label = AppStrings.fieldRequired,
  }) {
    return (value) {
      final trimmed = value?.trim() ?? '';

      if (trimmed.isEmpty) {
        return '$label ${'required'}';
      }

      return null;
    };
  }

  static String? Function(String?) website() {
    return (value) {
      final trimmed = value?.trim() ?? '';

      if (trimmed.isEmpty) {
        return AppStrings.websiteUrlRequired;
      }

      final urlPattern = RegExp(
        r'^(https?:\/\/)([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(\/[^\s]*)?$',
        caseSensitive: false,
      );

      if (!urlPattern.hasMatch(trimmed)) {
        return AppStrings.validWebsiteUrl;
      }

      return null;
    };
  }

  static String? Function(String?) name() {
    return (value) {
      final trimmed = value?.trim() ?? '';

      if (trimmed.isEmpty) {
        return AppStrings.nameRequired;
      }

      final nameRegex = RegExp(r'^[a-zA-Z\s.]{2,}$');

      if (!nameRegex.hasMatch(trimmed)) {
        return AppStrings.validName;
      }

      return null;
    };
  }

  static String? Function(String?) phone() {
    return (value) {
      final trimmed = value?.trim() ?? '';

      if (trimmed.isEmpty) {
        return AppStrings.phoneNumberRequired;
      }

      final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');

      if (!phoneRegex.hasMatch(trimmed)) {
        return AppStrings.validPhoneNumber;
      }

      return null;
    };
  }

  static String? Function(String?) username() {
    return (value) {
      final trimmed = value?.trim() ?? '';

      if (trimmed.isEmpty) {
        return AppStrings.usernameRequired;
      }

      final usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

      if (!usernameRegex.hasMatch(trimmed)) {
        return AppStrings.usernameInvalidLength;
      }

      return null;
    };
  }

  static String? Function(String?) number({
    String label = AppStrings.valueRequired,
  }) {
    return (value) {
      final trimmed = value?.trim() ?? '';

      if (trimmed.isEmpty) {
        return '$label ${'required'}';
      }

      if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(trimmed)) {
        return AppStrings.validNumber;
      }

      return null;
    };
  }

  static String? Function(String?) address() {
    return (value) {
      final trimmed = value?.trim() ?? '';

      if (trimmed.isEmpty) {
        return AppStrings.addressRequired;
      }

      if (trimmed.length < 5) {
        return AppStrings.validAddress;
      }

      return null;
    };
  }

  static String? Function(String?) city() {
    return (value) {
      final trimmed = value?.trim() ?? '';

      if (trimmed.isEmpty) {
        return AppStrings.cityRequired;
      }

      if (trimmed.length < 2) {
        return AppStrings.validCityName;
      }

      return null;
    };
  }

  static String? Function(String?) zipcode() {
    return (value) {
      final trimmed = value?.trim() ?? '';

      if (trimmed.isEmpty) {
        return AppStrings.zipcodeRequired;
      }

      if (!RegExp(r'^\d{4,10}$').hasMatch(trimmed)) {
        return AppStrings.validZipcode;
      }

      return null;
    };
  }

  static String? Function(String?) country() {
    return (value) {
      final trimmed = value?.trim() ?? '';

      if (trimmed.isEmpty) {
        return AppStrings.countryRequired;
      }

      if (trimmed.length < 2) {
        return AppStrings.validCountryName;
      }

      return null;
    };
  }

  static String? Function(String?) description({int minLength = 10}) {
    return (value) {
      final trimmed = value?.trim() ?? '';

      if (trimmed.isEmpty) {
        return AppStrings.descriptionRequired;
      }

      if (trimmed.length < minLength) {
        return "AppStrings.descriptionMinLengthParams({ 'min': minLength.toString(),})";
      }

      return null;
    };
  }

  String? Function(String?) postalCode() {
    return (value) {
      final trimmed = value?.trim() ?? '';

      if (trimmed.isEmpty) {
        return AppStrings.postalCodeRequired;
      }

      if (!RegExp(r'^[0-9]{4,10}$').hasMatch(trimmed)) {
        return AppStrings.validPostalCode;
      }

      return null;
    };
  }

  String? Function(String?) dateOfBirth() {
    return (value) {
      final trimmed = value?.trim() ?? '';

      if (trimmed.isEmpty) {
        return AppStrings.dateOfBirthRequired;
      }

      if (!RegExp(
        r'^(0[1-9]|[12][0-9]|3[01])[-/](0[1-9]|1[0-2])[-/](\d{4})$',
      ).hasMatch(trimmed)) {
        return AppStrings.validDateOfBirth;
      }

      final dateParts = trimmed.split(RegExp(r'[-/ ]'));

      final day = int.tryParse(dateParts[0]);
      final month = int.tryParse(dateParts[1]);
      final year = int.tryParse(dateParts[2]);

      if (day == null || month == null || year == null) {
        return AppStrings.invalidDateFormat;
      }

      try {
        final date = DateTime(year, month, day);

        if (date.isAfter(DateTime.now())) {
          return AppStrings.dateOfBirthFuture;
        }
      } catch (_) {
        return AppStrings.invalidDateOfBirth;
      }

      return null;
    };
  }

  String? Function(String?) gender() {
    return (value) {
      final trimmed = value?.trim() ?? '';

      if (trimmed.isEmpty) {
        return AppStrings.genderRequired;
      }

      if (!['male', 'female', 'other'].contains(trimmed.toLowerCase())) {
        return AppStrings.validGender;
      }

      return null;
    };
  }
}
