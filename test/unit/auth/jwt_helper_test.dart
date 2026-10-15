import 'dart:convert';

import 'package:aula360/core/utils/jwt_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String createTestJwt(Map<String, dynamic> payload) {
    final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'})));
    final body = base64Url.encode(utf8.encode(jsonEncode(payload)));
    final signature = base64Url.encode(utf8.encode('mock_signature'));
    return '$header.$body.$signature';
  }

  group('JwtHelper Unit Tests', () {
    test('extracts email from email claim in accessToken', () {
      final token = createTestJwt({
        'role': 'PARENT',
        'sub': '123e4567-e89b-12d3-a456-426614174000',
        'email': 'parent@example.com',
      });

      final email = JwtHelper.extractEmail(token);
      expect(email, equals('parent@example.com'));
    });

    test('extracts email from userEmail claim in accessToken', () {
      final token = createTestJwt({
        'role': 'TEACHER',
        'sub': 'user-123',
        'userEmail': 'teacher@example.com',
      });

      final email = JwtHelper.extractEmail(token);
      expect(email, equals('teacher@example.com'));
    });

    test('extracts email from sub claim when sub is an email address', () {
      final token = createTestJwt({
        'role': 'PARENT',
        'sub': 'john.doe@example.com',
      });

      final email = JwtHelper.extractEmail(token);
      expect(email, equals('john.doe@example.com'));
    });

    test('returns null when accessToken does not contain email', () {
      final token = createTestJwt({
        'role': 'PARENT',
        'sub': '7c49de18-04f0-477f-8125-1876143aba47',
        'deviceId': '603de628-d9fa-46ab-8e76-b889de9b8204',
        'accountStatus': 'ACTIVE',
      });

      final email = JwtHelper.extractEmail(token);
      expect(email, isNull);
    });

    test('returns null for invalid token strings', () {
      expect(JwtHelper.extractEmail(''), isNull);
      expect(JwtHelper.extractEmail(null), isNull);
      expect(JwtHelper.extractEmail('invalid.jwt'), isNull);
    });

    test('decode returns complete payload map', () {
      final token = createTestJwt({
        'role': 'PARENT',
        'sub': 'user-uuid',
        'accountStatus': 'ACTIVE',
      });

      final payload = JwtHelper.decode(token);
      expect(payload, isNotNull);
      expect(payload!['role'], equals('PARENT'));
      expect(payload['accountStatus'], equals('ACTIVE'));
    });

    test('extracts email with Bearer prefix', () {
      final token = createTestJwt({
        'role': 'PARENT',
        'email': 'bearer.user@example.com',
      });

      final email = JwtHelper.extractEmail('Bearer $token');
      expect(email, equals('bearer.user@example.com'));
    });

    test('extracts email from mail or identity claims', () {
      final mailToken = createTestJwt({'mail': 'mail@example.com'});
      expect(JwtHelper.extractEmail(mailToken), equals('mail@example.com'));

      final identityToken = createTestJwt({'identity': 'identity@example.com'});
      expect(JwtHelper.extractEmail(identityToken), equals('identity@example.com'));
    });

    test('extractRole and extractUserId extract correct claims', () {
      final token = createTestJwt({
        'role': 'TEACHER',
        'sub': 'user-id-999',
      });

      expect(JwtHelper.extractRole(token), equals('TEACHER'));
      expect(JwtHelper.extractUserId(token), equals('user-id-999'));
    });
  });
}
