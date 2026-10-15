import 'package:aula360/core/service/language/language_provider.dart';
import 'package:aula360/features/auth/data/dtos/media_dtos.dart';
import 'package:aula360/features/auth/domain/entities/auth_user.dart';
import 'package:aula360/utils/enum/app_enum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DTO and Model Parsing Tests', () {
    test('AuthUser parses valid Parent JSON', () {
      final json = {
        'id': 'usr_123',
        'fullName': 'Elena Vance',
        'email': 'elena@example.com',
        'phone': '+34612345678',
        'role': 'PARENT',
        'isProfileSetup': true,
        'avatarUrl': 'https://s3.amazonaws.com/avatar.jpg',
        'address': 'Calle Mayor 1',
        'relationWithChild': 'Madre',
      };

      final user = AuthUser.fromJson(json);
      expect(user.id, 'usr_123');
      expect(user.fullName, 'Elena Vance');
      expect(user.email, 'elena@example.com');
      expect(user.role, UserRole.parent);
      expect(user.role.isParent, isTrue);
      expect(user.isProfileSetup, isTrue);
      expect(user.avatarUrl, 'https://s3.amazonaws.com/avatar.jpg');
      expect(user.relationWithChild, 'Madre');
    });

    test('AuthUser parses valid Teacher JSON', () {
      final json = {
        'id': 'usr_456',
        'fullName': 'Dr. Marcos Vance',
        'email': 'marcos@example.com',
        'role': 'TEACHER',
        'isProfileSetup': false,
        'department': 'Matemáticas',
        'designation': 'Profesor Titular',
      };

      final user = AuthUser.fromJson(json);
      expect(user.id, 'usr_456');
      expect(user.fullName, 'Dr. Marcos Vance');
      expect(user.role, UserRole.teacher);
      expect(user.role.isTeacher, isTrue);
      expect(user.isProfileSetup, isFalse);
      expect(user.department, 'Matemáticas');
    });

    test(
      'AuthUser safely handles nulls, missing keys, and unexpected types',
      () {
        final malformedJson = <String, dynamic>{
          'id': null,
          'fullName': null,
          'email': null,
          'role': null,
          'isProfileSetup': null,
        };

        final user = AuthUser.fromJson(malformedJson);
        expect(user.id, '');
        expect(user.fullName, '');
        expect(user.email, '');
        expect(user.role, UserRole.parent); // safe default
        expect(user.isProfileSetup, isFalse);
      },
    );

    test('MediaUploadResponseDto parses array of AWS S3 URLs correctly', () {
      final json = {
        'success': true,
        'message': 'Media uploads successful',
        'data': [
          'https://alua-bucket.s3.amazonaws.com/attachments/img1.jpg',
          'https://alua-bucket.s3.amazonaws.com/attachments/img2.jpg',
        ],
        'traceId': 'trace_123',
      };

      final dto = MediaUploadResponseDto.fromJson(json);
      expect(dto.success, isTrue);
      expect(dto.urls.length, 2);
      expect(
        dto.urls.first,
        'https://alua-bucket.s3.amazonaws.com/attachments/img1.jpg',
      );
      expect(dto.traceId, 'trace_123');
    });

    test('MediaUploadResponseDto safely handles single URL or map list', () {
      final json = {
        'success': true,
        'message': 'Upload ok',
        'data': [
          {
            'url':
                'https://alua-bucket.s3.amazonaws.com/attachments/nested.png',
          },
        ],
      };

      final dto = MediaUploadResponseDto.fromJson(json);
      expect(dto.urls.length, 1);
      expect(
        dto.urls.first,
        'https://alua-bucket.s3.amazonaws.com/attachments/nested.png',
      );
    });

    test(
      'AuthUser parses /api/v1/auth/check response payload from auth.md exactly',
      () {
        final payload = {
          "userId": "123e4567-e89b-12d3-a456-426614174000",
          "fullName": "John Doe",
          "email": "john.doe@example.com",
          "phone": "+1234567890",
          "avatarUrl": "https://example.com/avatar.jpg",
          "role": "PARENT",
          "status": "ACTIVE",
          "isProfileSetup": true,
          "profileCompletedAt": "2026-10-14T09:50:00.000Z",
          "language": "EN",
        };

        final user = AuthUser.fromJson(payload);
        expect(user.id, '123e4567-e89b-12d3-a456-426614174000');
        expect(user.fullName, 'John Doe');
        expect(user.name, 'John Doe');
        expect(user.email, 'john.doe@example.com');
        expect(user.phone, '+1234567890');
        expect(user.avatarUrl, 'https://example.com/avatar.jpg');
        expect(user.role, UserRole.parent);
        expect(user.role.isParent, isTrue);
        expect(user.status, UserStatus.active);
        expect(user.isActive, isTrue);
        expect(user.isInactive, isFalse);
        expect(user.isProfileSetup, isTrue);
        expect(user.profileCompletedAt, '2026-10-14T09:50:00.000Z');
        expect(user.language, 'EN');
      },
    );

    test('AuthUser parses teacher /api/v1/auth/check payload correctly', () {
      final payload = {
        "userId": "teach-456-abc",
        "fullName": "Sarah Connor",
        "email": "sarah@school.edu",
        "phone": "+34600000000",
        "role": "TEACHER",
        "status": "ACTIVE",
        "isProfileSetup": true,
        "language": "ES",
      };

      final user = AuthUser.fromJson(payload);
      expect(user.id, 'teach-456-abc');
      expect(user.role, UserRole.teacher);
      expect(user.role.isTeacher, isTrue);
      expect(user.isActive, isTrue);
      expect(user.isProfileSetup, isTrue);
      expect(user.language, 'ES');
    });

    test(
      'AppLanguage.fromCode resolves casing, prefixes, and full names reliably',
      () {
        expect(AppLanguage.fromCode('EN'), AppLanguage.english);
        expect(AppLanguage.fromCode('en'), AppLanguage.english);
        expect(AppLanguage.fromCode('en_US'), AppLanguage.english);
        expect(AppLanguage.fromCode('English'), AppLanguage.english);

        expect(AppLanguage.fromCode('ES'), AppLanguage.spanish);
        expect(AppLanguage.fromCode('es'), AppLanguage.spanish);
        expect(AppLanguage.fromCode('es-ES'), AppLanguage.spanish);
        expect(AppLanguage.fromCode('Spanish'), AppLanguage.spanish);
        expect(AppLanguage.fromCode('Español'), AppLanguage.spanish);

        // Fallback for unknown
        expect(AppLanguage.fromCode('xyz'), AppLanguage.english);
        expect(AppLanguage.fromCode(''), AppLanguage.english);
      },
    );
  });
}

