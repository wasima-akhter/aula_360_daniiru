import 'package:aula360/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Environment and AppConfig Tests', () {
    test('Environment.fromString parses correctly with case insensitivity', () {
      expect(Environment.fromString('development'), Environment.development);
      expect(Environment.fromString('dev'), Environment.development);
      expect(Environment.fromString('STAGING'), Environment.staging);
      expect(Environment.fromString('stage'), Environment.staging);
      expect(Environment.fromString('production'), Environment.production);
      expect(Environment.fromString('prod'), Environment.production);
      expect(Environment.fromString('unknown'), Environment.development);
    });

    test('AppConfig.current provides valid defaults', () {
      final config = AppConfig.current;
      expect(config.baseUrl, isNotEmpty);
      expect(config.baseUrl, contains('http'));
      expect(config.serverBaseUrl, isNotEmpty);
      expect(config.environment, isA<Environment>());
      expect(config.flavor, isA<Flavor>());
    });

    test('AppConfig serverBaseUrl strips path correctly', () {
      const config = AppConfig(
        environment: Environment.development,
        flavor: Flavor.development,
        baseUrl: 'https://alua.localbox.online/api/v1',
      );
      expect(config.serverBaseUrl, equals('https://alua.localbox.online'));
    });
  });
}
