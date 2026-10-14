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
  });
}
