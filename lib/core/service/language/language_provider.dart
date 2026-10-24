import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/validators.dart';

// ─────────────────────────────────────────────
// Supported Languages
// ─────────────────────────────────────────────

enum AppLanguage {
  english('en', 'English', 'English (US)'),
  spanish('es', 'Spanish', 'Español');

  const AppLanguage(this.code, this.label, this.displayLabel);

  final String code;
  final String label;
  final String displayLabel;

  static AppLanguage fromCode(String code) {
    final normalized = code.trim().toLowerCase();
    return AppLanguage.values.firstWhere(
      (l) =>
          l.code.toLowerCase() == normalized ||
          l.label.toLowerCase() == normalized ||
          normalized.startsWith(l.code.toLowerCase()),
      orElse: () => AppLanguage.english,
    );
  }
}

// ─────────────────────────────────────────────
// Language State
// ─────────────────────────────────────────────

class LanguageState {
  final AppLanguage language;
  final Map<String, String> strings;

  const LanguageState({required this.language, required this.strings});

  String get languageCode => language.code;

  LanguageState copyWith({
    AppLanguage? language,
    Map<String, String>? strings,
  }) {
    return LanguageState(
      language: language ?? this.language,
      strings: strings ?? this.strings,
    );
  }

  /// Translate a key, falling back to active language fallback then alternate fallback or key itself.
  String tr(String key) {
    final val = strings[key];
    if (val != null && val.isNotEmpty) return val;

    if (language == AppLanguage.spanish) {
      return _spanishFallback[key] ?? _englishFallback[key] ?? key;
    }
    return _englishFallback[key] ?? _spanishFallback[key] ?? key;
  }
}

// ─────────────────────────────────────────────
// Language Notifier
// ─────────────────────────────────────────────

class LanguageNotifier extends AsyncNotifier<LanguageState> {
  static const _prefKey = 'app_language';
  static String activeLanguageCode = 'en';

  @override
  Future<LanguageState> build() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      final lang = saved != null
          ? AppLanguage.fromCode(saved)
          : AppLanguage.english;
      activeLanguageCode = lang.code;
      AulaValidation.activeLanguageCode = lang.code;
      final strings = await _loadStrings(lang.code);
      return LanguageState(language: lang, strings: strings);
    } catch (e, stack) {
      debugPrint('LanguageNotifier build error: $e\n$stack');
      activeLanguageCode = 'en';
      AulaValidation.activeLanguageCode = 'en';
      return LanguageState(
        language: AppLanguage.english,
        strings: _fallbackStrings('en'),
      );
    }
  }

  /// Change the app language and persist the choice.
  Future<void> changeLanguage(AppLanguage lang) async {
    activeLanguageCode = lang.code;
    AulaValidation.activeLanguageCode = lang.code;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, lang.code);
    } catch (e) {
      debugPrint('Could not save language preference: $e');
    }
    final strings = await _loadStrings(lang.code);
    state = AsyncData(LanguageState(language: lang, strings: strings));
  }

  /// Check if a language has already been chosen (used by splash).
  Future<bool> hasLanguageBeenChosen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_prefKey);
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, String>> _loadStrings(String code) async {
    try {
      final raw = await rootBundle.loadString('assets/lang/$code.json');
      final map = json.decode(raw) as Map<String, dynamic>;
      final result = <String, String>{};
      map.forEach((k, v) => result[k] = v.toString());
      return result;
    } catch (e) {
      debugPrint(
        'Warning: Could not load assets/lang/$code.json from bundle: $e',
      );
      return _fallbackStrings(code);
    }
  }

  static Map<String, String> _fallbackStrings(String code) {
    if (code == 'es') {
      return _spanishFallback;
    }
    return _englishFallback;
  }
}

// ─────────────────────────────────────────────
// Provider & Extensions
// ─────────────────────────────────────────────

final languageProvider = AsyncNotifierProvider<LanguageNotifier, LanguageState>(
  LanguageNotifier.new,
);

extension AsyncValueLanguageExt<T> on AsyncValue<T> {
  T? get valueOrNull => asData?.value;
}

// ─────────────────────────────────────────────
// Built-in Fallbacks (Guarantee safe loading)
// ─────────────────────────────────────────────

const Map<String, String> _englishFallback = {
  "app_name": "Aula 360",
  "app_tagline": "Empowering Modern Academies &\nConnected Learning",
  "app_initializing": "Initializing secure session...",
  "language_select_title": "Choose Your Language",
  "language_select_subtitle": "Select a language to continue with Aula 360",
  "language_english": "English",
  "language_spanish": "Spanish",
  "language_continue": "Continue",
  "select_language": "Select Language",
  "onboarding_skip": "Skip",
  "onboarding_next": "Next",
  "onboarding_continue": "Continue",
  "onboarding_title_1": "Centralized Academy\nIntelligence",
  "onboarding_desc_1":
      "Experience all-in-one academy management. Connect curriculum, classes, educators, and institutional operations in a unified cloud platform.",
  "onboarding_tag_unified_hub": "Unified Hub",
  "onboarding_tag_smart_timetables": "Smart Timetables",
  "onboarding_tag_realtime_sync": "Real-Time Sync",
  "onboarding_title_2": "Empowering Parents with\nClarity",
  "onboarding_desc_2":
      "Effortlessly monitor real-time attendance, track homework submissions, review weekly exam reports, and stay aligned with your student's learning journey.",
  "onboarding_tag_live_attendance": "Live Attendance",
  "onboarding_tag_homework_tracker": "Homework Tracker",
  "onboarding_tag_progress_reports": "Progress Reports",
  "onboarding_tag_class_schedules": "Class Schedules",
  "onboarding_title_3": "Direct Communication &\nGrowth",
  "onboarding_desc_3":
      "Instant two-way messaging with educators, urgent academy broadcasts, milestone badges, and comprehensive performance analytics at your fingertips.",
  "role_select_title": "Select your role",
  "role_select_subtitle": "Choose how you'll be accessing your academy portal.",
  "role_parent_title": "Parent /",
  "role_parent_subtitle": "Guardian",
  "role_parent_description":
      "Track your child's classes, attendance records, homework, and teacher updates.",
  "role_teacher_title": "Teacher / Educator",
  "role_teacher_description":
      "Manage classroom schedules, log daily attendance, post assignments, and communicate with parents.",
  "role_continue_as_parent": "Continue as Parent Login",
  "role_continue_as_teacher": "Continue as Teacher Login",
  "role_continue": "Continue",
  "parent_login_title": "Parent Login",
  "teacher_login_title": "Teacher Login",
  "welcome_back": "Welcome back",
  "parent_login_subtitle":
      "Enter your registered mobile number or email\naddress to access your parent account.",
  "teacher_login_subtitle":
      "Sign in with your academic credentials to access \nyour classes and schedules.",
  "field_mobile_or_email": "Mobile Number or Email",
  "field_mobile_or_email_hint": "e.g. parent@example.com or +1 (555) 019-28",
  "field_email_or_faculty_id": "Email or Faculty ID",
  "field_email_or_faculty_id_hint": "e.g. name@institution.edu",
  "field_password": "Password",
  "field_password_hint": "••••••••••••",
  "remember_device": "Remember this device",
  "forgot_password": "Forgot password?",
  "btn_login_aula360": "Log In to Aula 360",
  "no_account_yet": "Don't have an account? ",
  "create_account": "Create Account",
  "login_as_teacher": "Login as Teacher",
  "login_as_parent": "Login as Parent",
  "create_account_title": "Create Account",
  "create_your_account": "Create your account",
  "parent_signup_subtitle":
      "Enter your basic details to register and connect\nwith your child's academy.",
  "teacher_registration_title": "Teacher Registration",
  "register_as_faculty": "Register as Faculty",
  "teacher_signup_subtitle":
      "Enter your institutional details to initiate verified \nteacher access.",
  "field_full_name": "Full Name",
  "field_full_name_hint": "e.g. Eleanor Vance",
  "field_mobile_number": "Mobile Number",
  "field_mobile_hint": "(555) 234-5678",
  "field_email_address": "Email Address",
  "field_email_hint": "e.g. eleanor.vance@example.com",
  "field_academy_email": "Academy Email/Faculty ID",
  "field_academy_email_hint": "e.g. m.vance@institution.com",
  "field_password_create_hint": "Create a secure password",
  "password_hint_text": "At least 8 characters with uppercase, lowercase, and a special character",
  "btn_create_account": "Create Account",
  "already_have_account": "Already have an account? ",
  "log_in": "Log In",
  "agree_terms_prefix": "I agree to the ",
  "terms_and_conditions": "Terms and Conditions",
  "terms_and": " and ",
  "privacy_policy": "Privacy Policy",
  "forgot_password_header": "Forgot Password",
  "forgot_password_title": "Forgot your password?",
  "forgot_password_subtitle":
      "Enter the email address associated with your\naccount and we'll send you a verification code.",
  "field_email_registered": "Email Address",
  "field_email_registered_hint": "Enter your registered email",
  "btn_send_verification": "Send Verification Code",
  "reset_parent_password": "Reset Parent Password",
  "reset_teacher_password": "Reset Teacher Password",
  "reset_password_header": "Reset Password",
  "reset_password_title": "Create a new password",
  "reset_password_subtitle":
      "Choose a strong password that you haven't\nused before.",
  "field_new_password": "New Password",
  "field_new_password_hint": "Enter new password",
  "field_confirm_password": "Confirm Password",
  "field_confirm_password_hint": "Re-enter new password",
  "btn_reset_password": "Reset Password",
  "password_mismatch_title": "Password Mismatch",
  "password_mismatch_message": "Both passwords must match.",
  "password_reset_success_title": "Password Updated",
  "password_reset_success_message":
      "Your password has been reset successfully.",
  "otp_header": "Verification",
  "otp_verify_account": "Verify your account",
  "otp_verify_identity": "Verify your identity",
  "otp_signup_desc": "We sent a 6-digit verification code to:",
  "otp_forgot_desc": "We sent a 6-digit password reset code to:",
  "otp_enter_code_label": "ENTER 6-DIGIT CODE",
  "otp_expires_prefix": "Expires in 00:",
  "otp_resend": "Resend Code",
  "otp_spam_note":
      "Didn't receive a message? Check spam or resend once the timer expires.",
  "otp_verify_continue": "Verify & Continue",
  "otp_verify_reset": "Verify & Reset Password",
  "otp_required_title": "Verification Code Required",
  "otp_required_message": "Please enter all 6 digits of the verification code.",
  "home_greeting": "Good morning",
  "home_schedule": "Schedule",
  "home_in_person": "In-Person",
  "home_today": "TODAY",
  "home_classes_scheduled": "Classes Scheduled",
  "home_next_label": "NEXT",
  "home_attendance_label": "ATTENDANCE",
  "home_present_today": "Present Today",
  "home_attendance_history": "Attendance History",
  "home_todays_schedule": "Today's Schedule",
  "home_view_all": "View All",
  "home_switch": "Switch",
  "home_details": "Details",
  "home_campus_open": "Campus Open",
  "home_next_up": "NEXT UP",
  "home_starts": "Starts",
  "settings_title": "Settings",
  "settings_profile_breadcrumb": "Profile",
  "settings_section_language": "LANGUAGE",
  "settings_section_notifications": "NOTIFICATIONS",
  "settings_section_account_security": "ACCOUNT & SECURITY",
  "settings_section_account": "ACCOUNT",
  "settings_lang_display_language": "Display Language",
  "settings_lang_subtitle": "Choose the language used throughout the portal",
  "settings_lang_label": "Language",
  "settings_notif_class_reminders": "Class Reminders",
  "settings_notif_class_reminders_sub":
      "Receive reminders before scheduled classes",
  "settings_notif_parent_messages": "Parent Messages",
  "settings_notif_parent_messages_sub": "Receive messages from parents",
  "settings_notif_post_class": "Post-Class Reports",
  "settings_notif_post_class_sub":
      "Receive reminders to complete class reports",
  "settings_notif_push": "Push Notifications",
  "settings_notif_push_sub": "Receive class updates & reports",
  "settings_notif_email": "Email Notifications",
  "settings_notif_email_sub": "Receive reports and announcements via email",
  "settings_notif_attendance_alerts": "Attendance Alerts",
  "settings_notif_attendance_alerts_sub": "Instant check-in & absence notices",
  "settings_security_biometric": "Biometric Access",
  "settings_security_biometric_sub":
      "Use Face ID or fingerprint to unlock the portal",
  "settings_security_change_password": "Change Password",
  "settings_security_change_password_sub":
      "Update your academy account password",
  "settings_security_active_sessions": "Active Sessions",
  "settings_security_active_sessions_sub": "Manage devices currently signed in",
  "settings_sessions_title": "Active Sessions",
  "settings_sessions_subtitle":
      "These devices currently have access to your account.",
  "settings_sessions_signout_others": "Sign Out Other Sessions",
  "settings_sessions_current": "Current device",
  "settings_sessions_badge": "Active",
  "settings_biometric_enabled": "Biometric access enabled",
  "settings_biometric_disabled": "Biometric access disabled",
  "settings_class_reminders_enabled": "Class reminders enabled",
  "settings_class_reminders_disabled": "Class reminders disabled",
  "settings_parent_messages_enabled": "Parent messages enabled",
  "settings_parent_messages_disabled": "Parent messages disabled",
  "settings_post_class_enabled": "Post-class reports enabled",
  "settings_post_class_disabled": "Post-class reports disabled",
  "settings_lang_changed": "Language changed to",
  "settings_sessions_signedout": "Other sessions have been signed out",
  "change_password_title": "Change Password",
  "language_picker_title": "Select Language",
  "language_english_us": "English (US)",
  "language_spanish_label": "Spanish",
  "teacher_terms_required": "Please agree to the Terms and Conditions.",
  "dialer_not_supported": "Dialer is not supported on this device",
  "could_not_launch_dialer": "Could not launch dialer",
  "whatsapp_cannot_be_opened": "WhatsApp cannot be opened",
  "could_not_launch_whatsapp": "Could not launch WhatsApp",
  "good_morning": "Good morning",
  "good_afternoon": "Good afternoon",
  "good_evening": "Good evening",
  "good_night": "Good night",
  "email_required": "Email is required",
  "valid_email_address": "Please enter a valid email address",
  "password_required": "Password is required",
  "password_min_8": "Password must be at least 8 characters",
  "uppercase_required": "Password must contain at least one uppercase letter",
  "lowercase_required": "Password must contain at least one lowercase letter",
  "special_char_required": "Password must contain at least one special character",
  "number_required": "Password must contain at least one number",
  "invalid_phone_number": "Invalid phone number",
  "validation_error_title": "Validation Error",
  "validation_error_directive": "Please correct the indicated fields and try again.",
  "confirm_password_required": "Please confirm your password",
  "enter_password_first": "Please enter password first",
  "passwords_do_not_match": "Passwords do not match",
  "otp_required": "OTP is required",
  "otp_must_be_6_digits": "OTP must be 6 digits",
  "otp_numbers_only": "OTP must contain only numbers",
  "field_required": "This field is required",
  "field_is_required_suffix": "is required",
  "website_url_required": "Website URL is required",
  "valid_website_url": "Please enter a valid website URL",
  "name_required": "Name is required",
  "valid_name": "Please enter a valid name",
  "phone_number_required": "Phone number is required",
  "valid_phone_number": "Please enter a valid phone number",
  "username_required": "Username is required",
  "username_invalid_length":
      "Username must be 3-20 characters (letters, numbers, _)",
  "value_required": "Value is required",
  "valid_number": "Please enter a valid number",
  "address_required": "Address is required",
  "valid_address": "Please enter a valid address",
  "city_required": "City is required",
  "valid_city_name": "Please enter a valid city name",
  "zipcode_required": "Zip code is required",
  "valid_zipcode": "Please enter a valid zip code",
  "country_required": "Country is required",
  "valid_country_name": "Please enter a valid country name",
  "description_required": "Description is required",
  "postal_code_required": "Postal code is required",
  "valid_postal_code": "Please enter a valid postal code",
  "date_of_birth_required": "Date of birth is required",
  "valid_date_of_birth": "Please enter a valid date of birth (DD/MM/YYYY)",
  "invalid_date_format": "Invalid date format",
  "date_of_birth_future": "Date of birth cannot be in the future",
  "invalid_date_of_birth": "Invalid date of birth",
  "gender_required": "Gender is required",
  "valid_gender": "Please select a valid gender",
  "no_internet_connection": "No internet connection",
  "back": "Back",
  "see_less": "See less",
  "see_more": "See more",
  "something_went_wrong": "Something went wrong",
  "unknown_error_message": "An unexpected error occurred. Please try again.",
  "try_again": "Try Again",
  "retry": "Retry",
  "child_added_success": "Student registered successfully",
  "error_add_child": "Failed to enroll student",
  "no_children_linked": "No student linked",
  "no_children_linked_desc": "Link your child to view their schedule, classes, and attendance.",
  "no_classes_today": "No classes scheduled for today",
  "sessions_attended": "sessions attended this term",
  "no_data_available": "No data available",
  "date_of_birth": "Date of Birth",
  "something_went_wrong_retry": "Something went wrong. Tap to retry.",
  "no_items_found": "No items found",
  "list_currently_empty": "This list is currently empty.",
  "offline_message": "You are currently offline",
  "unable_to_play_video": "Unable to play video",
  "video_unavailable_or_connection_failed":
      "The video is unavailable or your connection failed.",
  "subject_math_advanced": "Advanced Mathematics",
  "subject_calculus_algebra": "Calculus & Algebra",
  "session_in_progress": "Session in progress",
  "floor_1": "1st Floor",
  "session_number_prefix": "Session",
  "session_prefix": "Session",
  "board_demonstration_title": "Board demonstration:",
  "board_demonstration_desc":
      "Great effort. Mastered the chain rule on the board with an excellent attitude.",
  "homework_demo_title": "Problem Set 4: Implicit Differentiation",
  "homework_demo_subtitle": "Exercises 12–25 • Notebook submission",
  "due_prefix": "Due:",
  "physical_copy": "In-hand copy",
  "faculty_default_note":
      "Demonstrates a solid conceptual understanding during board exercises. Actively helps classmates in Group A.",
  "group": "Group",
  "of_count": "of",
  "yesterday": "Yesterday",
  "subject_physical_education": "Physical Education",
  "subject_visual_arts": "Visual & Plastic Arts",
  "homework_submitted_success": "Successfully submitted on October 22.",
  "starts_in_hours": "Starts in 3h",
  "no_attendance_data": "No attendance records available",
  "today": "Today",
  "otp_resend_success": "Verification code resent to your email.",
  "notification_primer_title": "Never Miss an Important Update",
  "notification_primer_subtitle": "Get instant notifications for what matters most at Aula 360.",
  "notification_primer_benefit_1": "Real-time attendance & schedule updates",
  "notification_primer_benefit_2": "New report cards, grades & academic alerts",
  "notification_primer_benefit_3": "Urgent school announcements & payment receipts",
  "notification_primer_enable_btn": "Turn On Notifications",
  "notification_primer_later_btn": "Maybe Later",
  "notification_banner_title": "Push Notifications Are Off",
  "notification_banner_subtitle": "Enable alerts to stay updated with child progress & school notices.",
  "notification_banner_enable": "Enable",
  "legal_terms_and_conditions": "Terms & Conditions",
  "legal_terms_and_conditions_subtitle": "Read our terms of service and usage policies",
  "legal_privacy_policy": "Privacy Policy",
  "legal_privacy_policy_subtitle": "How we collect, use, and protect your data",
  "legal_about_us": "About Us",
  "legal_about_us_subtitle": "Learn more about Aula 360 Academy",
  "legal_data_protection": "Data Protection",
  "legal_data_protection_subtitle": "Our commitment to student and family data security",
  "legal_document_in_preparation": "Document in Preparation",
  "legal_document_in_preparation_desc": "The official document has not yet been published on the server by the Aula 360 administration.",
  "legal_view_general_info": "View General Information",
  "legal_view_saved_info": "View Saved Information",
  "legal_loading_document": "Loading document...",
  "legal_no_content_available": "No Content Available",
  "legal_no_content_desc": "This section currently has no published content.",
  "legal_no_internet_title": "No Internet Connection",
  "legal_no_internet_desc": "Could not connect to the server. Please verify your connection.",
  "legal_server_error_title": "Temporary Server Error",
  "legal_server_error_desc": "The legal service experienced a temporary issue.",
  "legal_generic_error_title": "Could Not Load Document",
  "legal_institutional_info": "Institutional Information",
  "legal_institutional_notice": "Official document pending publication by administration. Displaying general Aula 360 overview.",
  "legal_last_updated": "Last updated:",
  "legal_check_server": "Check Server for Updates",
  "notification_settings_denied_title": "Notifications Disabled",
  "notification_settings_denied_body": "Notifications are disabled in device settings. Open settings to enable.",
  "open_settings": "Settings",
  "no_attendance_records": "No attendance records",
  "no_attendance_records_desc": "No attendance sessions have been recorded for this period.",
  "no_homework_assigned": "No pending homework",
  "no_homework_assigned_desc": "All assigned homework for this category is up to date.",
  "no_pending_payments": "No pending payments",
  "no_pending_payments_desc": "All tuition and fee invoices are settled and up to date.",
  "realtime_chat": "REAL-TIME CHAT",
  "no_messages_yet": "No previous messages",
  "no_messages_yet_desc": "Send a message to start communicating directly.",
  "permission_denied_notice": "Notifications cannot be received until you grant permission in Settings.",
  "no_completed_classes": "No classes completed earlier today.",
  "messages": "Messages",
  "error_generic": "An error occurred",
  "no_due_date": "No due date",
  "chat_list_title": "Messages with Administration",
  "chat_with_admin": "Contact Administration",
  "no_conversations_title": "No conversations with Administration",
  "no_conversations_desc": "Start a chat with Aula 360 Administration for inquiries about schedules, payments, or school procedures.",
  "admin_name": "Aula 360 Administration",
  "typing_indicator": "Administration is typing...",
  "chat_online_channel": "Online • Official Channel",
  "chat_reconnecting": "Reconnecting to server...",
  "chat_reconnect_tooltip": "Reconnect to server",
  "chat_offline_title": "No connection to real-time server",
  "chat_offline_desc": "Messages will not be sent until connection is restored.",
  "chat_reconnect": "Reconnect",
  "chat_retry": "Retry",
  "chat_offline_strip": "No connection: message will not be sent until reconnected.",
  "chat_connection_required_notice": "No connection to chat server. Message will not be sent. Tap Reconnect.",
  "chat_send_failed_notice": "Failed to send message. Please check your connection and try again.",
  "chat_type_message_offline_hint": "Type your message (will send when connected)...",
  "live_badge": "ONLINE",
  "offline_badge": "OFFLINE",
  "chat_target_admin_not_found": "The administration chat user was not found on the server. Please contact school administration to initiate your chat channel.",
  "no_other_children_linked": "Only one child is registered in your account.",
  "switch_child_title": "Select Student",
  "switch_child_subtitle": "Select the active student for your dashboard",
  "switched_to_child": "Active student",
  "active_student": "Active",
  "enrolled_child_single": "Enrolled Child",
  "enrolled_children_plural": "Enrolled Children"
};

const Map<String, String> _spanishFallback = {
  "app_name": "Aula 360",
  "app_tagline": "Empoderando Academias Modernas &\nAprendizaje Conectado",
  "app_initializing": "Iniciando sesión segura...",
  "language_select_title": "Elige Tu Idioma",
  "language_select_subtitle":
      "Selecciona un idioma para continuar con Aula 360",
  "language_english": "Inglés",
  "language_spanish": "Español",
  "language_continue": "Continuar",
  "select_language": "Seleccionar Idioma",
  "onboarding_skip": "Omitir",
  "onboarding_next": "Siguiente",
  "onboarding_continue": "Continuar",
  "onboarding_title_1": "Inteligencia Académica\nCentralizada",
  "onboarding_desc_1":
      "Experimenta la gestión académica todo en uno. Conecta currículos, clases, educadores y operaciones institucionales en una plataforma unificada en la nube.",
  "onboarding_tag_unified_hub": "Centro Unificado",
  "onboarding_tag_smart_timetables": "Horarios Inteligentes",
  "onboarding_tag_realtime_sync": "Sincronización en Tiempo Real",
  "onboarding_title_2": "Empoderando a los Padres\ncon Claridad",
  "onboarding_desc_2":
      "Monitorea fácilmente la asistencia en tiempo real, rastrea envíos de tareas, revisa informes semanales y mantente alineado con el aprendizaje de tu estudiante.",
  "onboarding_tag_live_attendance": "Asistencia en Vivo",
  "onboarding_tag_homework_tracker": "Seguimiento de Tareas",
  "onboarding_tag_progress_reports": "Informes de Progreso",
  "onboarding_tag_class_schedules": "Horarios de Clases",
  "onboarding_title_3": "Comunicación Directa y\nCrecimiento",
  "onboarding_desc_3":
      "Mensajería instantánea bidireccional con educadores, transmisiones urgentes de la academia, insignias de hitos y análisis de rendimiento completo a tu alcance.",
  "role_select_title": "Selecciona tu rol",
  "role_select_subtitle": "Elige cómo accederás a tu portal académico.",
  "role_parent_title": "Padre /",
  "role_parent_subtitle": "Tutor",
  "role_parent_description":
      "Rastrea las clases, registros de asistencia, tareas y actualizaciones del maestro de tu hijo.",
  "role_teacher_title": "Maestro / Educador",
  "role_teacher_description":
      "Gestiona horarios de clases, registra asistencia diaria, publica tareas y comunícate con los padres.",
  "role_continue_as_parent": "Continuar como Inicio de Sesión de Padre",
  "role_continue_as_teacher": "Continuar como Inicio de Sesión de Maestro",
  "role_continue": "Continuar",
  "parent_login_title": "Inicio de Sesión del Padre",
  "teacher_login_title": "Inicio de Sesión del Maestro",
  "welcome_back": "Bienvenido de nuevo",
  "parent_login_subtitle":
      "Ingresa tu número de móvil o correo electrónico\nregistrado para acceder a tu cuenta de padre.",
  "teacher_login_subtitle":
      "Inicia sesión con tus credenciales académicas para acceder \na tus clases y horarios.",
  "field_mobile_or_email": "Número Móvil o Correo Electrónico",
  "field_mobile_or_email_hint": "ej. padre@ejemplo.com o +1 (555) 019-28",
  "field_email_or_faculty_id": "Correo Electrónico o ID de Facultad",
  "field_email_or_faculty_id_hint": "ej. nombre@institucion.edu",
  "field_password": "Contraseña",
  "field_password_hint": "••••••••••••",
  "remember_device": "Recordar este dispositivo",
  "forgot_password": "¿Olvidaste tu contraseña?",
  "btn_login_aula360": "Iniciar Sesión en Aula 360",
  "no_account_yet": "¿No tienes una cuenta? ",
  "create_account": "Crear Cuenta",
  "login_as_teacher": "Iniciar Sesión como Maestro",
  "login_as_parent": "Iniciar Sesión como Padre",
  "create_account_title": "Crear Cuenta",
  "create_your_account": "Crea tu cuenta",
  "parent_signup_subtitle":
      "Ingresa tus datos básicos para registrarte y conectarte\ncon la academia de tu hijo.",
  "teacher_registration_title": "Registro de Maestro",
  "register_as_faculty": "Registrarse como Docente",
  "teacher_signup_subtitle":
      "Ingresa tus datos institucionales para iniciar el acceso \nverificado de maestro.",
  "field_full_name": "Nombre Completo",
  "field_full_name_hint": "ej. Eleonora Vance",
  "field_mobile_number": "Número de Móvil",
  "field_mobile_hint": "(555) 234-5678",
  "field_email_address": "Correo Electrónico",
  "field_email_hint": "ej. eleonora.vance@ejemplo.com",
  "field_academy_email": "Correo de Academia/ID de Facultad",
  "field_academy_email_hint": "ej. m.vance@institucion.com",
  "field_password_create_hint": "Crea una contraseña segura",
  "password_hint_text": "Al menos 8 caracteres con mayúscula, minúscula y un carácter especial",
  "btn_create_account": "Crear Cuenta",
  "already_have_account": "¿Ya tienes una cuenta? ",
  "log_in": "Iniciar Sesión",
  "agree_terms_prefix": "Acepto los ",
  "terms_and_conditions": "Términos y Condiciones",
  "terms_and": " y la ",
  "privacy_policy": "Política de Privacidad",
  "forgot_password_header": "Contraseña Olvidada",
  "forgot_password_title": "¿Olvidaste tu contraseña?",
  "forgot_password_subtitle":
      "Ingresa el correo electrónico asociado a tu\ncuenta y te enviaremos un código de verificación.",
  "field_email_registered": "Correo Electrónico",
  "field_email_registered_hint": "Ingresa tu correo registrado",
  "btn_send_verification": "Enviar Código de Verificación",
  "reset_parent_password": "Restablecer Contraseña del Padre",
  "reset_teacher_password": "Restablecer Contraseña del Maestro",
  "reset_password_header": "Restablecer Contraseña",
  "reset_password_title": "Crear una nueva contraseña",
  "reset_password_subtitle":
      "Elige una contraseña segura que no hayas\nusado antes.",
  "field_new_password": "Nueva Contraseña",
  "field_new_password_hint": "Ingresa la nueva contraseña",
  "field_confirm_password": "Confirmar Contraseña",
  "field_confirm_password_hint": "Re-ingresa la nueva contraseña",
  "btn_reset_password": "Restablecer Contraseña",
  "password_mismatch_title": "Contraseñas No Coinciden",
  "password_mismatch_message": "Ambas contraseñas deben coincidir.",
  "password_reset_success_title": "Contraseña Actualizada",
  "password_reset_success_message":
      "Tu contraseña ha sido restablecida exitosamente.",
  "otp_header": "Verificación",
  "otp_verify_account": "Verifica tu cuenta",
  "otp_verify_identity": "Verifica tu identidad",
  "otp_signup_desc": "Enviamos un código de verificación de 6 dígitos a:",
  "otp_forgot_desc":
      "Enviamos un código de restablecimiento de contraseña de 6 dígitos a:",
  "otp_enter_code_label": "INGRESA CÓDIGO DE 6 DÍGITOS",
  "otp_expires_prefix": "Expira en 00:",
  "otp_resend": "Reenviar Código",
  "otp_spam_note":
      "¿No recibiste un mensaje? Revisa el spam o reenvía cuando expire el temporizador.",
  "otp_verify_continue": "Verificar y Continuar",
  "otp_verify_reset": "Verificar y Restablecer Contraseña",
  "otp_required_title": "Código de Verificación Requerido",
  "otp_required_message":
      "Por favor ingresa los 6 dígitos del código de verificación.",
  "home_greeting": "Buenos días",
  "home_schedule": "Horario",
  "home_in_person": "Presencial",
  "home_today": "HOY",
  "home_classes_scheduled": "Clases Programadas",
  "home_next_label": "SIGUIENTE",
  "home_attendance_label": "ASISTENCIA",
  "home_present_today": "Presente Hoy",
  "home_attendance_history": "Historial de Asistencia",
  "home_todays_schedule": "Horario de Hoy",
  "home_view_all": "Ver Todo",
  "home_switch": "Cambiar",
  "home_details": "Detalles",
  "home_campus_open": "Campus Abierto",
  "home_next_up": "PRÓXIMO",
  "home_starts": "Comienza",
  "settings_title": "Configuración",
  "settings_profile_breadcrumb": "Perfil",
  "settings_section_language": "IDIOMA",
  "settings_section_notifications": "NOTIFICACIONES",
  "settings_section_account_security": "CUENTA Y SEGURIDAD",
  "settings_section_account": "CUENTA",
  "settings_lang_display_language": "Idioma de Pantalla",
  "settings_lang_subtitle": "Elige el idioma usado en todo el portal",
  "settings_lang_label": "Idioma",
  "settings_notif_class_reminders": "Recordatorios de Clase",
  "settings_notif_class_reminders_sub":
      "Recibe recordatorios antes de las clases programadas",
  "settings_notif_parent_messages": "Mensajes de Padres",
  "settings_notif_parent_messages_sub": "Recibe mensajes de los padres",
  "settings_notif_post_class": "Informes Post-Clase",
  "settings_notif_post_class_sub":
      "Recibe recordatorios para completar informes de clase",
  "settings_notif_push": "Notificaciones Push",
  "settings_notif_push_sub": "Recibe actualizaciones de clase e informes",
  "settings_notif_email": "Notificaciones por Correo",
  "settings_notif_email_sub": "Recibe informes y anuncios por correo electrónico",
  "settings_notif_attendance_alerts": "Alertas de Asistencia",
  "settings_notif_attendance_alerts_sub":
      "Avisos instantáneos de check-in y ausencia",
  "settings_security_biometric": "Acceso Biométrico",
  "settings_security_biometric_sub":
      "Usa Face ID o huella dactilar para desbloquear el portal",
  "settings_security_change_password": "Cambiar Contraseña",
  "settings_security_change_password_sub":
      "Actualiza la contraseña de tu cuenta académica",
  "settings_security_active_sessions": "Sesiones Activas",
  "settings_security_active_sessions_sub":
      "Gestiona los dispositivos actualmente conectados",
  "settings_sessions_title": "Sesiones Activas",
  "settings_sessions_subtitle":
      "Estos dispositivos actualmente tienen acceso a tu cuenta.",
  "settings_sessions_signout_others": "Cerrar Sesión en Otros Dispositivos",
  "settings_sessions_current": "Dispositivo actual",
  "settings_sessions_badge": "Activo",
  "settings_biometric_enabled": "Acceso biométrico habilitado",
  "settings_biometric_disabled": "Acceso biométrico deshabilitado",
  "settings_class_reminders_enabled": "Recordatorios de clase habilitados",
  "settings_class_reminders_disabled": "Recordatorios de clase deshabilitados",
  "settings_parent_messages_enabled": "Mensajes de padres habilitados",
  "settings_parent_messages_disabled": "Mensajes de padres deshabilitados",
  "settings_post_class_enabled": "Informes post-clase habilitados",
  "settings_post_class_disabled": "Informes post-clase deshabilitados",
  "settings_lang_changed": "Idioma cambiado a",
  "settings_sessions_signedout": "Otras sesiones han sido cerradas",
  "change_password_title": "Cambiar Contraseña",
  "language_picker_title": "Seleccionar Idioma",
  "language_english_us": "Inglés (US)",
  "language_spanish_label": "Español",
  "teacher_terms_required": "Por favor acepta los Términos y Condiciones.",
  "dialer_not_supported": "El marcador no es compatible con este dispositivo",
  "could_not_launch_dialer": "No se pudo abrir el marcador",
  "whatsapp_cannot_be_opened": "No se puede abrir WhatsApp",
  "could_not_launch_whatsapp": "No se pudo abrir WhatsApp",
  "good_morning": "Buenos días",
  "good_afternoon": "Buenas tardes",
  "good_evening": "Buenas tardes",
  "good_night": "Buenas noches",
  "email_required": "El correo electrónico es requerido",
  "valid_email_address": "Por favor ingresa un correo electrónico válido",
  "password_required": "La contraseña es requerida",
  "password_min_8": "La contraseña debe tener al menos 8 caracteres",
  "uppercase_required":
      "La contraseña debe contener al menos una letra mayúscula",
  "lowercase_required":
      "La contraseña debe contener al menos una letra minúscula",
  "special_char_required":
      "La contraseña debe contener al menos un carácter especial",
  "number_required": "La contraseña debe contener al menos un número",
  "invalid_phone_number": "Número de teléfono no válido",
  "validation_error_title": "Error de validación",
  "validation_error_directive":
      "Por favor corrige los campos señalados e intenta de nuevo.",
  "confirm_password_required": "Por favor confirma tu contraseña",
  "enter_password_first": "Por favor ingresa la contraseña primero",
  "passwords_do_not_match": "Las contraseñas no coinciden",
  "otp_required": "El código OTP es requerido",
  "otp_must_be_6_digits": "El código OTP debe tener 6 dígitos",
  "otp_numbers_only": "El código OTP solo debe contener números",
  "field_required": "Este campo es requerido",
  "field_is_required_suffix": "es obligatorio",
  "website_url_required": "La URL del sitio web es requerida",
  "valid_website_url": "Por favor ingresa una URL de sitio web válida",
  "name_required": "El nombre es requerido",
  "valid_name": "Por favor ingresa un nombre válido",
  "phone_number_required": "El número de teléfono es requerido",
  "valid_phone_number": "Por favor ingresa un número de teléfono válido",
  "username_required": "El nombre de usuario es requerido",
  "username_invalid_length":
      "El usuario debe tener entre 3 y 20 caracteres (letras, números, _)",
  "value_required": "El valor es requerido",
  "valid_number": "Por favor ingresa un número válido",
  "address_required": "La dirección es requerida",
  "valid_address": "Por favor ingresa una dirección válida",
  "city_required": "La ciudad es requerida",
  "valid_city_name": "Por favor ingresa una ciudad válida",
  "zipcode_required": "El código postal es requerido",
  "valid_zipcode": "Por favor ingresa un código postal válido",
  "country_required": "El país es requerido",
  "valid_country_name": "Por favor ingresa un país válido",
  "description_required": "La descripción es requerida",
  "postal_code_required": "El código postal es requerido",
  "valid_postal_code": "Por favor ingresa un código postal válido",
  "date_of_birth_required": "La fecha de nacimiento es requerida",
  "valid_date_of_birth": "Por favor ingresa una fecha válida (DD/MM/AAAA)",
  "invalid_date_format": "Formato de fecha inválido",
  "date_of_birth_future": "La fecha de nacimiento no puede ser en el futuro",
  "invalid_date_of_birth": "Fecha de nacimiento inválida",
  "gender_required": "El género es requerido",
  "valid_gender": "Por favor selecciona un género válido",
  "no_internet_connection": "Sin conexión a internet",
  "back": "Atrás",
  "see_less": "Ver menos",
  "see_more": "Ver más",
  "something_went_wrong": "Algo salió mal",
  "unknown_error_message":
      "Ocurrió un error inesperado. Por favor intenta de nuevo.",
  "try_again": "Intentar de nuevo",
  "retry": "Reintentar",
  "child_added_success": "Estudiante matriculado con éxito",
  "error_add_child": "Error al matricular estudiante",
  "no_children_linked": "Sin alumnos vinculados",
  "no_children_linked_desc": "Vincule a su hijo/a para ver su horario, clases y asistencia.",
  "no_classes_today": "No hay clases programadas para hoy",
  "sessions_attended": "sesiones asistidas este trimestre",
  "no_data_available": "No hay información disponible",
  "date_of_birth": "Fecha de Nacimiento",
  "something_went_wrong_retry": "Algo salió mal. Toca para reintentar.",
  "no_items_found": "No se encontraron elementos",
  "list_currently_empty": "Esta lista está vacía actualmente.",
  "offline_message": "Actualmente estás desconectado",
  "unable_to_play_video": "No se puede reproducir el video",
  "video_unavailable_or_connection_failed":
      "El video no está disponible o falló la conexión.",
  "subject_math_advanced": "Matemáticas Avanzadas",
  "subject_calculus_algebra": "Cálculo y Álgebra",
  "session_in_progress": "Sesión en curso",
  "floor_1": "Planta 1",
  "session_number_prefix": "Sesión",
  "session_prefix": "Sesión",
  "board_demonstration_title": "Demostración en pizarra:",
  "board_demonstration_desc":
      "Gran esfuerzo. Dominó la regla de la cadena en la pizarra con excelente actitud.",
  "homework_demo_title": "Relación de ejercicios 4: Derivación implícita",
  "homework_demo_subtitle": "Ejercicios 12–25 • Entrega en cuaderno",
  "due_prefix": "Entrega:",
  "physical_copy": "Copia en mano",
  "faculty_default_note":
      "Demuestra un sólido entendimiento conceptual en los ejercicios de pizarra. Ayuda activamente a sus compañeros del Grupo A.",
  "group": "Grupo",
  "of_count": "de",
  "yesterday": "Ayer",
  "subject_physical_education": "Educación Física",
  "subject_visual_arts": "Educación Plástica y Visual",
  "homework_submitted_success": "Entregada correctamente el 22 de Octubre.",
  "starts_in_hours": "Comienza en 3h",
  "no_attendance_data": "No hay registros de asistencia disponibles",
  "today": "Hoy",
  "otp_resend_success": "Código de verificación reenviado a tu correo electrónico.",
  "notification_primer_title": "No te pierdas ninguna novedad",
  "notification_primer_subtitle": "Recibe alertas al instante sobre lo más importante en Aula 360.",
  "notification_primer_benefit_1": "Asistencia en tiempo real y cambios de horario",
  "notification_primer_benefit_2": "Nuevos boletines de notas, calificaciones y alertas",
  "notification_primer_benefit_3": "Avisos escolares urgentes y recibos de pago",
  "notification_primer_enable_btn": "Activar notificaciones",
  "notification_primer_later_btn": "Ahora no",
  "notification_banner_title": "Notificaciones desactivadas",
  "notification_banner_subtitle": "Activa las alertas para mantenerte informado del progreso escolar.",
  "notification_banner_enable": "Activar",
  "legal_terms_and_conditions": "Términos y Condiciones",
  "legal_terms_and_conditions_subtitle": "Consulta nuestras condiciones de servicio y normativas de uso",
  "legal_privacy_policy": "Política de Privacidad",
  "legal_privacy_policy_subtitle": "Cómo recopilamos, usamos y protegemos tus datos",
  "legal_about_us": "Sobre Nosotros",
  "legal_about_us_subtitle": "Conoce más sobre la academia Aula 360",
  "legal_data_protection": "Protección de Datos",
  "legal_data_protection_subtitle": "Nuestro compromiso con la seguridad de datos de alumnos y familias",
  "legal_document_in_preparation": "Documento en preparación",
  "legal_document_in_preparation_desc": "El documento oficial aún no ha sido publicado en el servidor por la administración de Aula 360.",
  "legal_view_general_info": "Ver información general",
  "legal_view_saved_info": "Ver información guardada",
  "legal_loading_document": "Cargando documento...",
  "legal_no_content_available": "Sin contenido disponible",
  "legal_no_content_desc": "Esta sección no cuenta con texto publicado en este momento.",
  "legal_no_internet_title": "Sin conexión a internet",
  "legal_no_internet_desc": "No se pudo conectar con el servidor. Verifica tu conexión.",
  "legal_server_error_title": "Error temporal del servidor",
  "legal_server_error_desc": "El servicio legal experimentó un problema temporal.",
  "legal_generic_error_title": "No se pudo cargar el documento",
  "legal_institutional_info": "Información Institucional",
  "legal_institutional_notice": "Documento oficial pendiente de publicación por la administración. Mostrando información general de Aula 360.",
  "legal_last_updated": "Última actualización:",
  "legal_check_server": "Comprobar publicación en servidor",
  "notification_settings_denied_title": "Notificaciones Desactivadas",
  "notification_settings_denied_body": "Las notificaciones están desactivadas en los ajustes del dispositivo. Abre los ajustes para activarlas.",
  "open_settings": "Ajustes",
  "no_attendance_records": "No hay registros de asistencia",
  "no_attendance_records_desc": "Aún no se han registrado sesiones de asistencia para este periodo.",
  "no_homework_assigned": "No hay tareas pendientes",
  "no_homework_assigned_desc": "Todas las tareas asignadas para esta categoría están al día.",
  "no_pending_payments": "No hay pagos pendientes",
  "no_pending_payments_desc": "Todas las cuotas y matrículas escolares están al día.",
  "realtime_chat": "CHAT EN TIEMPO REAL",
  "no_messages_yet": "Sin mensajes previos",
  "no_messages_yet_desc": "Escribe un mensaje para comunicarte directamente.",
  "permission_denied_notice": "No podrás recibir notificaciones hasta que otorgues el permiso en Ajustes.",
  "no_completed_classes": "No hay clases completadas antes hoy.",
  "messages": "Mensajes",
  "error_generic": "Ocurrió un error",
  "no_due_date": "Sin fecha límite",
  "chat_list_title": "Mensajes con Administración",
  "chat_with_admin": "Contactar Administración",
  "no_conversations_title": "Sin conversaciones con Administración",
  "no_conversations_desc": "Inicia un chat con la administración de Aula 360 para cualquier consulta sobre horarios, pagos o trámites.",
  "admin_name": "Administración Aula 360",
  "typing_indicator": "La administración está escribiendo...",
  "chat_online_channel": "En línea • Canal Oficial",
  "chat_reconnecting": "Reconectando con el servidor...",
  "chat_reconnect_tooltip": "Reconectar servidor",
  "chat_offline_title": "Sin conexión con el servidor en tiempo real",
  "chat_offline_desc": "Los mensajes no se enviarán hasta que la conexión se restablezca.",
  "chat_reconnect": "Reconectar",
  "chat_retry": "Reintentar",
  "chat_offline_strip": "Sin conexión: el mensaje no se enviará hasta reconectar.",
  "chat_connection_required_notice": "Sin conexión al servidor de chat. El mensaje no se enviará. Pulsa Reconectar.",
  "chat_send_failed_notice": "No se pudo enviar el mensaje. Verifica tu conexión e inténtalo de nuevo.",
  "chat_type_message_offline_hint": "Escribe tu mensaje (se enviará al conectar)...",
  "live_badge": "EN LÍNEA",
  "offline_badge": "DESCONECTADO",
  "chat_target_admin_not_found": "El usuario de administración no fue encontrado en el servidor. Contacta con secretaría para habilitar tu canal de chat.",
  "no_other_children_linked": "Solo hay un alumno registrado en tu cuenta.",
  "switch_child_title": "Seleccionar Alumno",
  "switch_child_subtitle": "Selecciona el alumno activo para tu panel",
  "switched_to_child": "Alumno activo",
  "active_student": "Activo",
  "enrolled_child_single": "Hijo Matriculado",
  "enrolled_children_plural": "Hijos Matriculados"
};
