import 'package:aula360/features/profile/data/dtos/parent_profile_dto.dart';
import 'package:aula360/features/profile/data/dtos/teacher_profile_dto.dart';
import 'package:aula360/features/settings/data/dtos/user_settings_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Profile and Settings DTOs Tests', () {
    test('ParentProfileDto parses 200 response from GET /api/v1/profile/parent', () {
      final json = {
        "userId": "123e4567-e89b-12d3-a456-426614174000",
        "fullName": "Eleanor Rivera",
        "email": "eleanor@example.com",
        "phone": "+15551234",
        "avatarUrl": "https://example.com/avatar.jpg",
        "language": "EN",
        "createdAt": "2026-10-13T10:00:00.000Z",
        "occupation": "Architect",
        "address": "742 Evergreen Terrace",
        "relationWithChild": "Mother"
      };

      final dto = ParentProfileDto.fromJson(json);
      expect(dto.userId, "123e4567-e89b-12d3-a456-426614174000");
      expect(dto.fullName, "Eleanor Rivera");
      expect(dto.email, "eleanor@example.com");
      expect(dto.phone, "+15551234");
      expect(dto.avatarUrl, "https://example.com/avatar.jpg");
      expect(dto.language, "EN");
      expect(dto.occupation, "Architect");
      expect(dto.address, "742 Evergreen Terrace");
      expect(dto.relationWithChild, "Mother");
    });

    test('UpdateParentProfileDto serializes for POST /api/v1/profile/parent', () {
      const dto = UpdateParentProfileDto(
        fullName: "Eleanor Rivera",
        avatarUrl: "https://example.com/avatar.jpg",
        phone: "+15551234",
        occupation: "Architect",
        address: "742 Evergreen Terrace",
        relationWithChild: "Mother",
      );

      final json = dto.toJson();
      expect(json['fullName'], "Eleanor Rivera");
      expect(json['avatarUrl'], "https://example.com/avatar.jpg");
      expect(json['phone'], "+15551234");
      expect(json['occupation'], "Architect");
      expect(json['address'], "742 Evergreen Terrace");
      expect(json['relationWithChild'], "Mother");
    });

    test('TeacherProfileDto parses 200 response from GET /api/v1/profile/teacher', () {
      final json = {
        "userId": "123e4567-e89b-12d3-a456-426614174000",
        "fullName": "Dr. Sarah Jenkins",
        "email": "sarah.jenkins@aula360.edu",
        "phone": "+15552045",
        "avatarUrl": "https://example.com/avatar.jpg",
        "language": "EN",
        "createdAt": "2026-10-13T10:00:00.000Z",
        "department": "Mathematics",
        "designation": "Head of Mathematics & STEM Faculty",
        "bio": "Over 15 years of teaching experience."
      };

      final dto = TeacherProfileDto.fromJson(json);
      expect(dto.userId, "123e4567-e89b-12d3-a456-426614174000");
      expect(dto.fullName, "Dr. Sarah Jenkins");
      expect(dto.email, "sarah.jenkins@aula360.edu");
      expect(dto.phone, "+15552045");
      expect(dto.avatarUrl, "https://example.com/avatar.jpg");
      expect(dto.language, "EN");
      expect(dto.department, "Mathematics");
      expect(dto.designation, "Head of Mathematics & STEM Faculty");
      expect(dto.bio, "Over 15 years of teaching experience.");
    });

    test('UpdateTeacherProfileDto serializes for POST /api/v1/profile/teacher', () {
      const dto = UpdateTeacherProfileDto(
        fullName: "Dr. Sarah Jenkins",
        avatarUrl: "https://example.com/avatar.jpg",
        phone: "+15552045",
        department: "Mathematics",
        designation: "Head of Mathematics & STEM Faculty",
        bio: "Over 15 years of teaching experience.",
      );

      final json = dto.toJson();
      expect(json['fullName'], "Dr. Sarah Jenkins");
      expect(json['avatarUrl'], "https://example.com/avatar.jpg");
      expect(json['phone'], "+15552045");
      expect(json['department'], "Mathematics");
      expect(json['designation'], "Head of Mathematics & STEM Faculty");
      expect(json['bio'], "Over 15 years of teaching experience.");
    });

    test('UserSettingsDto parses 200 response from GET /api/v1/settings', () {
      final json = {
        "language": "EN",
        "notifications": {
          "push": true,
          "email": false,
        }
      };

      final dto = UserSettingsDto.fromJson(json);
      expect(dto.language, "EN");
      expect(dto.notifications.push, isTrue);
      expect(dto.notifications.email, isFalse);
    });

    test('ChangePasswordRequestDto serializes for POST /api/v1/settings/password', () {
      const dto = ChangePasswordRequestDto(
        currentPassword: "OldPassw0rd!",
        newPassword: "NewPassw0rd@2026",
      );

      final json = dto.toJson();
      expect(json['currentPassword'], "OldPassw0rd!");
      expect(json['newPassword'], "NewPassw0rd@2026");
    });

    test('UpdateLanguageRequestDto serializes for POST /api/v1/settings/language', () {
      const dto = UpdateLanguageRequestDto(language: "ES");
      final json = dto.toJson();
      expect(json['language'], "ES");
    });

    test('UpdateNotificationPreferencesRequestDto serializes for POST /api/v1/settings/notification', () {
      const dto = UpdateNotificationPreferencesRequestDto(
        push: true,
        email: false,
      );
      final json = dto.toJson();
      expect(json['push'], isTrue);
      expect(json['email'], isFalse);
    });
  });
}
