import 'package:aula360/core/utils/formatters/app_input_formatters.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String applyFormatters(List<TextInputFormatter> formatters, String input) {
    var oldValue = TextEditingValue.empty;
    var newValue = TextEditingValue(
      text: input,
      selection: TextSelection.collapsed(offset: input.length),
    );

    for (final formatter in formatters) {
      newValue = formatter.formatEditUpdate(oldValue, newValue);
      oldValue = newValue;
    }

    return newValue.text;
  }

  group('AppInputFormatters Unit Tests', () {
    test('email formatter blocks whitespace and line breaks', () {
      final result = applyFormatters(
        AppInputFormatters.email,
        ' test @example .com \n',
      );
      expect(result, equals('test@example.com'));
    });

    test('phone formatter blocks letters and symbols, keeps digits, +, space, hyphen, and parens', () {
      final result = applyFormatters(
        AppInputFormatters.phone,
        '+34 (612) abc 345 - def 678',
      );
      expect(result, equals('+34 (612)  345 -  678'));
    });

    test('name formatter blocks numbers and symbols, keeps accented chars, hyphens, and spaces', () {
      final result = applyFormatters(
        AppInputFormatters.name,
        'María José Álvarez-Smith 123!@#',
      );
      expect(result, equals('María José Álvarez-Smith '));
    });

    test('password formatter blocks whitespace and newlines', () {
      final result = applyFormatters(
        AppInputFormatters.password,
        'Secret P@ss 123 \t\n',
      );
      expect(result, equals('SecretP@ss123'));
    });

    test('digitsOnly formatter only allows digits', () {
      final result = applyFormatters(
        AppInputFormatters.digitsOnly,
        '+34 (612) 345',
      );
      expect(result, equals('34612345'));
    });
  });
}
