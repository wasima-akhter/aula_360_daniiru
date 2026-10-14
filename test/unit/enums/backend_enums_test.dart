import 'package:aula360/core/enums/backend_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Backend Enums Preservation and Serialization Tests', () {
    test('Role enum parses and serializes correctly', () {
      expect(Role.fromString('PARENT'), equals(Role.parent));
      expect(Role.fromString('TEACHER'), equals(Role.teacher));
      expect(Role.fromString('ADMIN'), equals(Role.admin));
      expect(Role.parent.serializedName, equals('PARENT'));
    });

    test('UserStatus enum parses and serializes correctly', () {
      expect(UserStatus.fromString('ACTIVE'), equals(UserStatus.active));
      expect(UserStatus.fromString('INACTIVE'), equals(UserStatus.inactive));
      expect(UserStatus.fromString('SUSPENDED'), equals(UserStatus.suspended));
    });

    test('StudentStatus enum parses and serializes correctly', () {
      expect(StudentStatus.fromString('ACTIVE'), equals(StudentStatus.active));
      expect(
        StudentStatus.fromString('INACTIVE'),
        equals(StudentStatus.inactive),
      );
      expect(
        StudentStatus.fromString('WITHDRAWN'),
        equals(StudentStatus.withdrawn),
      );
    });

    test('EnrollmentStatus enum parses and serializes correctly', () {
      expect(
        EnrollmentStatus.fromString('ACTIVE'),
        equals(EnrollmentStatus.active),
      );
      expect(
        EnrollmentStatus.fromString('WITHDRAWN'),
        equals(EnrollmentStatus.withdrawn),
      );
    });

    test('CohortStatus enum parses and serializes correctly', () {
      expect(CohortStatus.fromString('ACTIVE'), equals(CohortStatus.active));
      expect(
        CohortStatus.fromString('INACTIVE'),
        equals(CohortStatus.inactive),
      );
      expect(
        CohortStatus.fromString('ARCHIVED'),
        equals(CohortStatus.archived),
      );
    });

    test('SessionStatus enum parses and serializes correctly', () {
      expect(
        SessionStatus.fromString('SCHEDULED'),
        equals(SessionStatus.scheduled),
      );
      expect(
        SessionStatus.fromString('ONGOING'),
        equals(SessionStatus.ongoing),
      );
      expect(
        SessionStatus.fromString('COMPLETED'),
        equals(SessionStatus.completed),
      );
      expect(
        SessionStatus.fromString('CANCELLED'),
        equals(SessionStatus.cancelled),
      );
    });

    test('AttendanceStatus enum parses and serializes correctly', () {
      expect(
        AttendanceStatus.fromString('PRESENT'),
        equals(AttendanceStatus.present),
      );
      expect(
        AttendanceStatus.fromString('ABSENT'),
        equals(AttendanceStatus.absent),
      );
      expect(
        AttendanceStatus.fromString('LATE'),
        equals(AttendanceStatus.late),
      );
      expect(
        AttendanceStatus.fromString('EXCUSED'),
        equals(AttendanceStatus.excused),
      );
    });

    test('ReportStatus enum parses and serializes correctly', () {
      expect(
        ReportStatus.fromString('SUBMITTED'),
        equals(ReportStatus.submitted),
      );
      expect(
        ReportStatus.fromString('REVIEWED'),
        equals(ReportStatus.reviewed),
      );
    });

    test('AttitudeRating enum parses and serializes correctly', () {
      expect(
        AttitudeRating.fromString('NEEDS_ATTENTION'),
        equals(AttitudeRating.needsAttention),
      );
      expect(
        AttitudeRating.fromString('SATISFACTORY'),
        equals(AttitudeRating.satisfactory),
      );
      expect(
        AttitudeRating.fromString('EXCELLENT'),
        equals(AttitudeRating.excellent),
      );
    });

    test('WorkEffortRating enum parses and serializes correctly', () {
      expect(
        WorkEffortRating.fromString('MODERATE'),
        equals(WorkEffortRating.moderate),
      );
      expect(
        WorkEffortRating.fromString('ON_TRACK'),
        equals(WorkEffortRating.onTrack),
      );
      expect(
        WorkEffortRating.fromString('HIGH_EFFORT'),
        equals(WorkEffortRating.highEffort),
      );
    });

    test('HomeworkStatus enum parses and serializes correctly', () {
      expect(
        HomeworkStatus.fromString('PENDING'),
        equals(HomeworkStatus.pending),
      );
      expect(
        HomeworkStatus.fromString('COMPLETED'),
        equals(HomeworkStatus.completed),
      );
      expect(
        HomeworkStatus.fromString('OVERDUE'),
        equals(HomeworkStatus.overdue),
      );
    });

    test('InvoiceStatus enum parses and serializes correctly', () {
      expect(
        InvoiceStatus.fromString('PENDING'),
        equals(InvoiceStatus.pending),
      );
      expect(InvoiceStatus.fromString('PAID'), equals(InvoiceStatus.paid));
      expect(
        InvoiceStatus.fromString('OVERDUE'),
        equals(InvoiceStatus.overdue),
      );
      expect(
        InvoiceStatus.fromString('CANCELLED'),
        equals(InvoiceStatus.cancelled),
      );
    });

    test('PaymentStatus enum parses and serializes correctly', () {
      expect(
        PaymentStatus.fromString('PENDING'),
        equals(PaymentStatus.pending),
      );
      expect(
        PaymentStatus.fromString('SUCCEEDED'),
        equals(PaymentStatus.succeeded),
      );
      expect(PaymentStatus.fromString('FAILED'), equals(PaymentStatus.failed));
      expect(
        PaymentStatus.fromString('REFUNDED'),
        equals(PaymentStatus.refunded),
      );
    });

    test('ConversationType enum parses and serializes correctly', () {
      expect(
        ConversationType.fromString('PARENT_ADMIN'),
        equals(ConversationType.parentAdmin),
      );
      expect(
        ConversationType.fromString('TEACHER_ADMIN'),
        equals(ConversationType.teacherAdmin),
      );
    });

    test('Language enum parses and serializes correctly', () {
      expect(Language.fromString('EN'), equals(Language.en));
      expect(Language.fromString('ES'), equals(Language.es));
    });

    test('AnnouncementAudience enum parses and serializes correctly', () {
      expect(
        AnnouncementAudience.fromString('PARENTS'),
        equals(AnnouncementAudience.parents),
      );
      expect(
        AnnouncementAudience.fromString('TEACHERS'),
        equals(AnnouncementAudience.teachers),
      );
    });

    test('Platform enum parses and serializes correctly', () {
      expect(Platform.fromString('ANDROID'), equals(Platform.android));
      expect(Platform.fromString('IOS'), equals(Platform.ios));
    });

    test('DeviceStatus enum parses and serializes correctly', () {
      expect(DeviceStatus.fromString('ACTIVE'), equals(DeviceStatus.active));
      expect(
        DeviceStatus.fromString('INACTIVE'),
        equals(DeviceStatus.inactive),
      );
      expect(
        DeviceStatus.fromString('LOGGED_OUT'),
        equals(DeviceStatus.loggedOut),
      );
      expect(DeviceStatus.fromString('REVOKED'), equals(DeviceStatus.revoked));
    });

    test('RevokeReason enum parses and serializes correctly', () {
      expect(
        RevokeReason.fromString('NEW_LOGIN_SUPERSEDED'),
        equals(RevokeReason.newLoginSuperseded),
      );
      expect(
        RevokeReason.fromString('FCM_SUPERSEDED'),
        equals(RevokeReason.fcmSuperseded),
      );
      expect(
        RevokeReason.fromString('SESSION_EXPIRED'),
        equals(RevokeReason.sessionExpired),
      );
      expect(
        RevokeReason.fromString('FCM_INVALID_TOKEN'),
        equals(RevokeReason.fcmInvalidToken),
      );
      expect(
        RevokeReason.fromString('ADMIN_KICK'),
        equals(RevokeReason.adminKick),
      );
    });

    test('NotificationType enum parses and serializes correctly', () {
      expect(
        NotificationType.fromString('FEE_CREATED'),
        equals(NotificationType.feeCreated),
      );
      expect(
        NotificationType.fromString('PAYMENT_SUCCESS'),
        equals(NotificationType.paymentSuccess),
      );
      expect(
        NotificationType.fromString('PAYMENT_FAILED'),
        equals(NotificationType.paymentFailed),
      );
      expect(
        NotificationType.fromString('INVOICE_OVERDUE'),
        equals(NotificationType.invoiceOverdue),
      );
      expect(
        NotificationType.fromString('REPORT_SUBMITTED'),
        equals(NotificationType.reportSubmitted),
      );
      expect(
        NotificationType.fromString('PASSWORD_RESET'),
        equals(NotificationType.passwordReset),
      );
    });

    test('ScheduleStatus enum parses and serializes correctly', () {
      expect(
        ScheduleStatus.fromString('CONFIRMED'),
        equals(ScheduleStatus.confirmed),
      );
      expect(
        ScheduleStatus.fromString('TENTATIVE'),
        equals(ScheduleStatus.tentative),
      );
      expect(
        ScheduleStatus.fromString('CANCELLED'),
        equals(ScheduleStatus.cancelled),
      );
    });

    test('SubjectStatus enum parses and serializes correctly', () {
      expect(SubjectStatus.fromString('ACTIVE'), equals(SubjectStatus.active));
      expect(
        SubjectStatus.fromString('INACTIVE'),
        equals(SubjectStatus.inactive),
      );
      expect(
        SubjectStatus.fromString('ARCHIVED'),
        equals(SubjectStatus.archived),
      );
    });

    test('LegalContentType enum parses and serializes correctly', () {
      expect(
        LegalContentType.fromString('ABOUT_US'),
        equals(LegalContentType.aboutUs),
      );
      expect(
        LegalContentType.fromString('TERMS_AND_CONDITION'),
        equals(LegalContentType.termsAndCondition),
      );
      expect(
        LegalContentType.fromString('PRIVACY_AND_POLICY'),
        equals(LegalContentType.privacyAndPolicy),
      );
      expect(
        LegalContentType.fromString('DATA_PROTECTION'),
        equals(LegalContentType.dataProtection),
      );
    });

    test('WebhookEventStatus enum parses and serializes correctly', () {
      expect(
        WebhookEventStatus.fromString('RECEIVED'),
        equals(WebhookEventStatus.received),
      );
      expect(
        WebhookEventStatus.fromString('PROCESSED'),
        equals(WebhookEventStatus.processed),
      );
      expect(
        WebhookEventStatus.fromString('FAILED'),
        equals(WebhookEventStatus.failed),
      );
    });

    test('ApiErrorType enum parses known failure codes', () {
      expect(
        ApiErrorType.fromString('INVALID_CREDENTIALS'),
        equals(ApiErrorType.invalidCredentials),
      );
      expect(
        ApiErrorType.fromString('USER_NOT_FOUND'),
        equals(ApiErrorType.userNotFound),
      );
      expect(
        ApiErrorType.fromString('USER_SUSPENDED'),
        equals(ApiErrorType.userSuspended),
      );
      expect(
        ApiErrorType.fromString('INVALID_OTP'),
        equals(ApiErrorType.invalidOtp),
      );
      expect(
        ApiErrorType.fromString('OTP_EXPIRED'),
        equals(ApiErrorType.otpExpired),
      );
      expect(
        ApiErrorType.fromString('TOKEN_EXPIRED'),
        equals(ApiErrorType.tokenExpired),
      );
      expect(
        ApiErrorType.fromString('SESSION_EXPIRED'),
        equals(ApiErrorType.sessionExpired),
      );
      expect(
        ApiErrorType.fromString('RATE_LIMIT_EXCEEDED'),
        equals(ApiErrorType.rateLimitExceeded),
      );
      expect(
        ApiErrorType.fromString('UNKNOWN_XYZ'),
        equals(ApiErrorType.unknown),
      );
    });
  });
}
