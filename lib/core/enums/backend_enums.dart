/// ============================================================================
/// BACKEND & DOMAIN INTEGRATION ENUMS
/// ============================================================================
/// Comprehensive enums matching the backend database models and API specifications.
/// Includes bi-directional serialization (UPPER_CASE API names <-> lowerCamelCase Dart),
/// safe fallback parsing, and display labels for future system integrations.
library;

import 'dart:io' as io;

// ─────────────────────────────────────────────────────────────────────────────
// 1. Role & Identity
// ─────────────────────────────────────────────────────────────────────────────

enum Role {
  parent('PARENT'),
  teacher('TEACHER'),
  admin('ADMIN');

  const Role(this.serializedName);
  final String serializedName;

  static Role fromString(String? raw, {Role fallback = Role.parent}) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return Role.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

enum UserStatus {
  active('ACTIVE'),
  inactive('INACTIVE'),
  suspended('SUSPENDED');

  const UserStatus(this.serializedName);
  final String serializedName;

  static UserStatus fromString(
    String? raw, {
    UserStatus fallback = UserStatus.active,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return UserStatus.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

enum StudentStatus {
  active('ACTIVE'),
  inactive('INACTIVE'),
  withdrawn('WITHDRAWN');

  const StudentStatus(this.serializedName);
  final String serializedName;

  static StudentStatus fromString(
    String? raw, {
    StudentStatus fallback = StudentStatus.active,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return StudentStatus.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

enum EnrollmentStatus {
  active('ACTIVE'),
  withdrawn('WITHDRAWN');

  const EnrollmentStatus(this.serializedName);
  final String serializedName;

  static EnrollmentStatus fromString(
    String? raw, {
    EnrollmentStatus fallback = EnrollmentStatus.active,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return EnrollmentStatus.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

enum CohortStatus {
  active('ACTIVE'),
  inactive('INACTIVE'),
  archived('ARCHIVED');

  const CohortStatus(this.serializedName);
  final String serializedName;

  static CohortStatus fromString(
    String? raw, {
    CohortStatus fallback = CohortStatus.active,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return CohortStatus.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Academic Sessions & Attendance
// ─────────────────────────────────────────────────────────────────────────────

enum SessionStatus {
  scheduled('SCHEDULED'),
  ongoing('ONGOING'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  const SessionStatus(this.serializedName);
  final String serializedName;

  static SessionStatus fromString(
    String? raw, {
    SessionStatus fallback = SessionStatus.scheduled,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return SessionStatus.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

enum AttendanceStatus {
  present('PRESENT'),
  absent('ABSENT'),
  late('LATE'),
  excused('EXCUSED');

  const AttendanceStatus(this.serializedName);
  final String serializedName;

  static AttendanceStatus fromString(
    String? raw, {
    AttendanceStatus fallback = AttendanceStatus.present,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return AttendanceStatus.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

enum ReportStatus {
  submitted('SUBMITTED'),
  reviewed('REVIEWED');

  const ReportStatus(this.serializedName);
  final String serializedName;

  static ReportStatus fromString(
    String? raw, {
    ReportStatus fallback = ReportStatus.submitted,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return ReportStatus.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

enum AttitudeRating {
  needsAttention('NEEDS_ATTENTION'),
  satisfactory('SATISFACTORY'),
  excellent('EXCELLENT');

  const AttitudeRating(this.serializedName);
  final String serializedName;

  static AttitudeRating fromString(
    String? raw, {
    AttitudeRating fallback = AttitudeRating.satisfactory,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return AttitudeRating.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

enum WorkEffortRating {
  moderate('MODERATE'),
  onTrack('ON_TRACK'),
  highEffort('HIGH_EFFORT');

  const WorkEffortRating(this.serializedName);
  final String serializedName;

  static WorkEffortRating fromString(
    String? raw, {
    WorkEffortRating fallback = WorkEffortRating.onTrack,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return WorkEffortRating.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

enum HomeworkStatus {
  pending('PENDING'),
  completed('COMPLETED'),
  overdue('OVERDUE');

  const HomeworkStatus(this.serializedName);
  final String serializedName;

  static HomeworkStatus fromString(
    String? raw, {
    HomeworkStatus fallback = HomeworkStatus.pending,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return HomeworkStatus.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Billing & Payments
// ─────────────────────────────────────────────────────────────────────────────

enum InvoiceStatus {
  pending('PENDING'),
  paid('PAID'),
  overdue('OVERDUE'),
  cancelled('CANCELLED');

  const InvoiceStatus(this.serializedName);
  final String serializedName;

  static InvoiceStatus fromString(
    String? raw, {
    InvoiceStatus fallback = InvoiceStatus.pending,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return InvoiceStatus.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

enum PaymentStatus {
  pending('PENDING'),
  succeeded('SUCCEEDED'),
  failed('FAILED'),
  refunded('REFUNDED');

  const PaymentStatus(this.serializedName);
  final String serializedName;

  static PaymentStatus fromString(
    String? raw, {
    PaymentStatus fallback = PaymentStatus.pending,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return PaymentStatus.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Communication & Messaging
// ─────────────────────────────────────────────────────────────────────────────

enum ConversationType {
  parentAdmin('PARENT_ADMIN'),
  teacherAdmin('TEACHER_ADMIN');

  const ConversationType(this.serializedName);
  final String serializedName;

  static ConversationType fromString(
    String? raw, {
    ConversationType fallback = ConversationType.parentAdmin,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return ConversationType.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

enum AnnouncementAudience {
  parents('PARENTS'),
  teachers('TEACHERS');

  const AnnouncementAudience(this.serializedName);
  final String serializedName;

  static AnnouncementAudience fromString(
    String? raw, {
    AnnouncementAudience fallback = AnnouncementAudience.parents,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return AnnouncementAudience.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. Localization & Platform
// ─────────────────────────────────────────────────────────────────────────────

enum Language {
  en('EN'),
  es('ES');

  const Language(this.serializedName);
  final String serializedName;

  static Language fromString(String? raw, {Language fallback = Language.en}) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return Language.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

enum Platform {
  android('ANDROID'),
  ios('IOS');

  const Platform(this.serializedName);
  final String serializedName;

  static bool get isIOS => io.Platform.isIOS;
  static bool get isAndroid => io.Platform.isAndroid;
  static bool get isWindows => io.Platform.isWindows;
  static bool get isMacOS => io.Platform.isMacOS;
  static bool get isLinux => io.Platform.isLinux;

  static Platform fromString(
    String? raw, {
    Platform fallback = Platform.android,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return Platform.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. Device & Session Security
// ─────────────────────────────────────────────────────────────────────────────

enum DeviceStatus {
  active('ACTIVE'),
  inactive('INACTIVE'),
  loggedOut('LOGGED_OUT'),
  revoked('REVOKED');

  const DeviceStatus(this.serializedName);
  final String serializedName;

  static DeviceStatus fromString(
    String? raw, {
    DeviceStatus fallback = DeviceStatus.active,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return DeviceStatus.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

enum RevokeReason {
  newLoginSuperseded('NEW_LOGIN_SUPERSEDED'),
  fcmSuperseded('FCM_SUPERSEDED'),
  sessionExpired('SESSION_EXPIRED'),
  fcmInvalidToken('FCM_INVALID_TOKEN'),
  adminKick('ADMIN_KICK');

  const RevokeReason(this.serializedName);
  final String serializedName;

  static RevokeReason fromString(
    String? raw, {
    RevokeReason fallback = RevokeReason.sessionExpired,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return RevokeReason.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. Notifications
// ─────────────────────────────────────────────────────────────────────────────

enum NotificationType {
  feeCreated('FEE_CREATED'),
  paymentSuccess('PAYMENT_SUCCESS'),
  paymentFailed('PAYMENT_FAILED'),
  invoiceOverdue('INVOICE_OVERDUE'),
  reportSubmitted('REPORT_SUBMITTED'),
  reportReviewed('REPORT_REVIEWED'),
  homeworkAssigned('HOMEWORK_ASSIGNED'),
  sessionReminder('SESSION_REMINDER'),
  childAbsent('CHILD_ABSENT'),
  newMessage('NEW_MESSAGE'),
  announcement('ANNOUNCEMENT'),
  accountVerified('ACCOUNT_VERIFIED'),
  passwordReset('PASSWORD_RESET');

  const NotificationType(this.serializedName);
  final String serializedName;

  static NotificationType fromString(
    String? raw, {
    NotificationType fallback = NotificationType.announcement,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return NotificationType.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 8. Schedules & Subjects
// ─────────────────────────────────────────────────────────────────────────────

enum ScheduleStatus {
  confirmed('CONFIRMED'),
  tentative('TENTATIVE'),
  cancelled('CANCELLED');

  const ScheduleStatus(this.serializedName);
  final String serializedName;

  static ScheduleStatus fromString(
    String? raw, {
    ScheduleStatus fallback = ScheduleStatus.confirmed,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return ScheduleStatus.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

enum SubjectStatus {
  active('ACTIVE'),
  inactive('INACTIVE'),
  archived('ARCHIVED');

  const SubjectStatus(this.serializedName);
  final String serializedName;

  static SubjectStatus fromString(
    String? raw, {
    SubjectStatus fallback = SubjectStatus.active,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return SubjectStatus.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 9. Legal & Webhooks
// ─────────────────────────────────────────────────────────────────────────────

enum LegalContentType {
  aboutUs('ABOUT_US'),
  termsAndCondition('TERMS_AND_CONDITION'),
  privacyAndPolicy('PRIVACY_AND_POLICY'),
  dataProtection('DATA_PROTECTION');

  const LegalContentType(this.serializedName);
  final String serializedName;

  static LegalContentType fromString(
    String? raw, {
    LegalContentType fallback = LegalContentType.aboutUs,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return LegalContentType.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

enum WebhookEventStatus {
  received('RECEIVED'),
  processed('PROCESSED'),
  failed('FAILED');

  const WebhookEventStatus(this.serializedName);
  final String serializedName;

  static WebhookEventStatus fromString(
    String? raw, {
    WebhookEventStatus fallback = WebhookEventStatus.received,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return WebhookEventStatus.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 10. API Failure Error Types (From Backend errorType response)
// ─────────────────────────────────────────────────────────────────────────────

enum ApiErrorType {
  invalidCredentials('INVALID_CREDENTIALS'),
  userNotFound('USER_NOT_FOUND'),
  userInactive('USER_INACTIVE'),
  accountInactive('ACCOUNT_INACTIVE'),
  userSuspended('USER_SUSPENDED'),
  userWithdrawn('USER_WITHDRAWN'),
  invalidOtp('INVALID_OTP'),
  otpExpired('OTP_EXPIRED'),
  emailAlreadyExists('EMAIL_ALREADY_EXISTS'),
  phoneAlreadyExists('PHONE_ALREADY_EXISTS'),
  unauthorized('UNAUTHORIZED'),
  tokenExpired('TOKEN_EXPIRED'),
  sessionExpired('SESSION_EXPIRED'),
  forbidden('FORBIDDEN'),
  notFound('NOT_FOUND'),
  validationError('VALIDATION_ERROR'),
  fileTooLarge('FILE_TOO_LARGE'),
  invalidFileType('INVALID_FILE_TYPE'),
  rateLimitExceeded('RATE_LIMIT_EXCEEDED'),
  serverError('SERVER_ERROR'),
  networkError('NETWORK_ERROR'),
  unknown('UNKNOWN');

  const ApiErrorType(this.serializedName);
  final String serializedName;

  static ApiErrorType fromString(
    String? raw, {
    ApiErrorType fallback = ApiErrorType.unknown,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return ApiErrorType.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () {
        if (normalized == 'ACCOUNT_INACTIVE' || normalized.contains('INACTIVE')) {
          return ApiErrorType.accountInactive;
        }
        if (normalized.contains('CREDENTIAL')) {
          return ApiErrorType.invalidCredentials;
        }
        if (normalized.contains('USER') && normalized.contains('NOT_FOUND')) {
          return ApiErrorType.userNotFound;
        }
        if (normalized.contains('OTP') && normalized.contains('EXPIRED')) {
          return ApiErrorType.otpExpired;
        }
        if (normalized.contains('OTP')) {
          return ApiErrorType.invalidOtp;
        }
        if (normalized.contains('TOKEN') || normalized.contains('SESSION')) {
          return ApiErrorType.sessionExpired;
        }
        if (normalized.contains('AUTH') || normalized.contains('UNAUTHORIZED')) {
          return ApiErrorType.unauthorized;
        }
        return fallback;
      },
    );
  }
}
