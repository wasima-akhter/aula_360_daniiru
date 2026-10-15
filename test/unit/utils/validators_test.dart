import 'package:aula360/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AulaValidation Unit Tests', () {
    test('sanitizePhone cleans formatting characters while preserving +', () {
      expect(AulaValidation.sanitizePhone('(555) 234-5678'), equals('5552345678'));
      expect(
        AulaValidation.sanitizePhone('+1 (555) 234-5678'),
        equals('+15552345678'),
      );
      expect(
        AulaValidation.sanitizePhone('+34 612 345 678'),
        equals('+34612345678'),
      );
      expect(AulaValidation.sanitizePhone(' 123-456-7890 '), equals('1234567890'));
      expect(AulaValidation.sanitizePhone(''), equals(''));
    });

    test('getMissingPasswordRequirements detects uppercase, lowercase, special char, length', () {
      // 1. All missing
      final missingAllEn = AulaValidation.getMissingPasswordRequirements(
        '123',
        languageCode: 'en',
      );
      expect(missingAllEn, contains('Password must be at least 8 characters'));
      expect(missingAllEn, contains('Password must contain at least one uppercase letter'));
      expect(missingAllEn, contains('Password must contain at least one lowercase letter'));
      expect(missingAllEn, contains('Password must contain at least one special character'));

      // 2. Spanish translations
      final missingAllEs = AulaValidation.getMissingPasswordRequirements(
        '123',
        languageCode: 'es',
      );
      expect(missingAllEs, contains('La contraseña debe tener al menos 8 caracteres'));
      expect(missingAllEs, contains('La contraseña debe contener al menos una letra mayúscula'));
      expect(missingAllEs, contains('La contraseña debe contener al menos una letra minúscula'));
      expect(missingAllEs, contains('La contraseña debe contener al menos un carácter especial'));

      // 3. Missing uppercase and special character (e.g. "password123")
      final missingPartial = AulaValidation.getMissingPasswordRequirements(
        'password123',
        languageCode: 'en',
      );
      expect(missingPartial, hasLength(2));
      expect(missingPartial, contains('Password must contain at least one uppercase letter'));
      expect(missingPartial, contains('Password must contain at least one special character'));

      // 4. Valid strong password satisfies all criteria
      final valid = AulaValidation.getMissingPasswordRequirements(
        'SecureP@ss123',
        languageCode: 'en',
      );
      expect(valid, isEmpty);

      // 5. activeLanguageCode fallback defaults to English
      AulaValidation.activeLanguageCode = 'en';
      final defaultEn = AulaValidation.getMissingPasswordRequirements('123');
      expect(defaultEn, contains('Password must be at least 8 characters'));

      // 6. activeLanguageCode fallback when switched to Spanish
      AulaValidation.activeLanguageCode = 'es';
      final defaultEs = AulaValidation.getMissingPasswordRequirements('123');
      expect(defaultEs, contains('La contraseña debe tener al menos 8 caracteres'));

      // Reset back to English
      AulaValidation.activeLanguageCode = 'en';
    });

    test('validatePhone returns dynamically translated error strings or null', () {
      // Empty input
      expect(
        AulaValidation.validatePhone('', languageCode: 'en'),
        equals('Please enter your phone number.'),
      );
      expect(
        AulaValidation.validatePhone('', languageCode: 'es'),
        equals('Por favor, introduce tu número de teléfono.'),
      );

      // Invalid input (non-allowed characters)
      expect(
        AulaValidation.validatePhone('abc', languageCode: 'en'),
        equals('Invalid phone number'),
      );
      expect(
        AulaValidation.validatePhone('abc', languageCode: 'es'),
        equals('Número de teléfono no válido'),
      );

      // Invalid input (too short)
      expect(
        AulaValidation.validatePhone('123', languageCode: 'en'),
        equals('Invalid phone number (must be 8-15 digits)'),
      );
      expect(
        AulaValidation.validatePhone('123', languageCode: 'es'),
        equals('Número de teléfono no válido (debe tener entre 8 y 15 dígitos)'),
      );

      // Valid input
      expect(
        AulaValidation.validatePhone('+34612345678', languageCode: 'en'),
        isNull,
      );
      expect(
        AulaValidation.validatePhone('+34612345678', languageCode: 'es'),
        isNull,
      );
    });

    test('validateEmail returns dynamically translated error strings or null', () {
      expect(
        AulaValidation.validateEmail('', languageCode: 'en'),
        equals('Please enter your email address.'),
      );
      expect(
        AulaValidation.validateEmail('', languageCode: 'es'),
        equals('Por favor, introduce tu correo electrónico.'),
      );
      expect(
        AulaValidation.validateEmail('invalid-mail', languageCode: 'en'),
        equals('Please enter a valid email address.'),
      );
      expect(
        AulaValidation.validateEmail('invalid-mail', languageCode: 'es'),
        equals('Por favor, introduce un correo electrónico válido.'),
      );
      expect(
        AulaValidation.validateEmail('test@aula360.com', languageCode: 'en'),
        isNull,
      );
    });

    test('validateRequired returns dynamically translated error strings or null', () {
      expect(
        AulaValidation.validateRequired('', fieldName: 'Full Name', languageCode: 'en'),
        equals('Full Name is required.'),
      );
      expect(
        AulaValidation.validateRequired('', fieldName: 'Nombre completo', languageCode: 'es'),
        equals('Nombre completo es obligatorio.'),
      );
      expect(
        AulaValidation.validateRequired('John Doe', fieldName: 'Full Name', languageCode: 'en'),
        isNull,
      );
    });
  });
}

