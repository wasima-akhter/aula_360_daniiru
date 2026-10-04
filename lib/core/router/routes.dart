import 'package:aula360/features/auth/presentation/parent_auth/profile_setup_screen.dart';
import 'package:aula360/features/auth/presentation/teacher_auth/teacher_login_screen.dart';
import 'package:aula360/features/auth/presentation/teacher_auth/teacher_sign_up_screen.dart';
import 'package:aula360/features/parent_all/chat/chat_inbox_screen.dart';
import 'package:aula360/features/parent_all/children/add_children_screen.dart';
import 'package:aula360/features/parent_all/children/child_profile_screen.dart';
import 'package:aula360/features/parent_all/children/my_children_screen.dart';
import 'package:aula360/features/parent_all/class_details/class_details_screen.dart';
import 'package:aula360/features/parent_all/payment/payment_screen.dart';
import 'package:aula360/features/parent_all/reports/homework/parent_homework_detail_screen.dart';
import 'package:aula360/features/parent_all/reports/homework/parent_homework_screen.dart';
import 'package:aula360/features/parent_all/reports/parent_report_detail_screen.dart';
import 'package:aula360/features/parent_all/reports/parent_report_screen.dart';
import 'package:aula360/features/parent_all/schedule/schedule_screen.dart';
import 'package:aula360/features/parent_all/settings/settings_screen.dart';
import 'package:aula360/features/teacher_all/attendance/teacher_end_class_screen.dart';
import 'package:aula360/features/teacher_all/attendance/teacher_report_submit_confirm_screen.dart';
import 'package:aula360/features/teacher_all/attendance/teacher_submit_report_screen.dart';
import 'package:aula360/features/teacher_all/reports/teacher_report_detail_screen.dart';
import 'package:aula360/features/teacher_all/students/teacher_student_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/parent_auth/login_screen.dart';
import '../../features/auth/presentation/parent_auth/sign_up_screen.dart';
import '../../features/auth/presentation/screens/active_otp_screen.dart';
import '../../features/auth/presentation/screens/forget_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/teacher_auth/teacher_profile_setup_screen.dart';
import '../../features/entry/presentation/screens/choose_role_screen.dart';
import '../../features/entry/presentation/screens/onboarding_screen.dart';
import '../../features/entry/presentation/screens/splash_screen.dart';
import '../../features/nav/presentation/screens/navigation_page.dart';
import '../../features/parent_all/attendance/attendance_screen.dart';
import '../../features/parent_all/helper/parent_home_helper.dart';
import '../../features/parent_all/payment/payment_receipt_screen.dart';
import '../../features/parent_all/profile/parent_edit_profile_screen.dart';
import '../../features/parent_all/teacher_info/teacher_info_screen.dart';
import '../../features/teacher_all/attendance/teacher_attendance_screen.dart';
import '../../features/teacher_all/classes/teacher_class_detail_screen.dart';
import '../../features/teacher_all/profile/teacher_edit_profile_screen.dart';
import '../../features/teacher_all/settings/change_password_screen.dart';
import '../../features/teacher_all/settings/teacher_settings_screen.dart';
import '../../utils/extension/base_extension.dart';
import 'route_path.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: RoutePath.splashScreen.addBasePath,
    debugLogDiagnostics: true,
    navigatorKey: navigatorKey,
    routes: [
      // routes...
      // ===================================================== // INITIAL ROUTES // ===================================================== GoRoute( name: RoutePath.splashScreen, path: RoutePath.splashScreen.addBasePath, pageBuilder: (context, state) { return _buildPageWithAnimation( state: state, child: const SplashScreen(), ); }, ), // ===================================================== // ONBOARDING ROUTES // =====================================================
      GoRoute(
        name: RoutePath.splashScreen,
        path: RoutePath.splashScreen.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: const SplashScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.chooseRoleScreen,
        path: RoutePath.chooseRoleScreen.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: const ChooseRoleScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.onboardingScreen,
        path: RoutePath.onboardingScreen.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: const OnboardingScreen(),
          );
        },
      ),
      // ===================================================== // AUTHENTICATION ROUTES // =====================================================
      GoRoute(
        name: RoutePath.loginScreen,
        path: RoutePath.loginScreen.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: const LoginScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.teacherLoginScreen,
        path: RoutePath.teacherLoginScreen.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: const TeacherLoginScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.signUpScreen,
        path: RoutePath.signUpScreen.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: const SignUpScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.teacherSignUpScreen,
        path: RoutePath.teacherSignUpScreen.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: const TeacherSignUpScreen(),
          );
        },
      ),

      GoRoute(
        name: RoutePath.activeOtpScreen,
        path: RoutePath.activeOtpScreen.addBasePath,
        pageBuilder: (context, state) {
          final extra = state.extra as OtpArgs?;
          return _buildPageWithAnimation(
            state: state,
            child: ActiveOtpScreen(
              args: OtpArgs(
                purpose: extra?.purpose ?? OtpPurpose.forgotPassword,
                role: extra?.role ?? OtpRole.parent,
              ),
            ),
          );
        },
      ),

      // ===================================================== // MAIN NAVIGATION
      GoRoute(
        name: RoutePath.forgetPasswordScreen,
        path: RoutePath.forgetPasswordScreen.addBasePath,
        pageBuilder: (context, state) {
          final args = state.extra as ForgotPasswordArgs;

          return _buildPageWithAnimation(
            state: state,
            child: ForgetPasswordScreen(args: args),
          );
        },
      ),

      GoRoute(
        name: RoutePath.resetPasswordScreen,
        path: RoutePath.resetPasswordScreen.addBasePath,
        pageBuilder: (context, state) {
          final email = state.extra as String?;

          return _buildPageWithAnimation(
            state: state,
            child: ResetPasswordScreen(email: email),
          );
        },
      ),

      //
      //
      GoRoute(
        name: RoutePath.profileSetup,
        path: RoutePath.profileSetup.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: ProfileSetupScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.teacherProfileSetup,
        path: RoutePath.teacherProfileSetup.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: TeacherProfileSetupScreen(),
          );
        },
      ),

      GoRoute(
        name: RoutePath.navigationPages,
        path: RoutePath.navigationPages.addBasePath,
        pageBuilder: (context, state) {
          final index = state.extra as int? ?? 0;

          return _buildPageWithAnimation(
            state: state,
            child: NavigationPage(index: index),
          );
        },
      ),

      // ROLE based screens
      //
      GoRoute(
        name: RoutePath.classDetail,
        path: RoutePath.classDetail.addBasePath,
        pageBuilder: (context, state) {
          final extra = state.extra as ClassModel;

          return _buildPageWithAnimation(
            state: state,
            child: ClassDetailsScreen(classData: extra),
          );
        },
      ),

      GoRoute(
        name: RoutePath.schedule,
        path: RoutePath.schedule.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(state: state, child: ScheduleScreen());
        },
      ),
      GoRoute(
        name: RoutePath.reportDetail,
        path: RoutePath.reportDetail.addBasePath,
        pageBuilder: (context, state) {
          final extra = state.extra as ReportModel;
          return _buildPageWithAnimation(
            state: state,
            child: ReportDetailsScreen(report: extra),
          );
        },
      ),
      GoRoute(
        name: RoutePath.homework,
        path: RoutePath.homework.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(state: state, child: HomeworkScreen());
        },
      ),
      GoRoute(
        name: RoutePath.homeworkDetail,
        path: RoutePath.homeworkDetail.addBasePath,
        pageBuilder: (context, state) {
          final extra = state.extra as HomeworkModel;
          return _buildPageWithAnimation(
            state: state,
            child: HomeworkDetailsScreen(homework: extra),
          );
        },
      ),
      GoRoute(
        name: RoutePath.teacherInformation,
        path: RoutePath.teacherInformation.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: TeacherInformationScreen(),
          );
        },
      ),
      // -------------
      GoRoute(
        name: RoutePath.chatInbox,
        path: RoutePath.chatInbox.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: TeacherChatScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.payment,
        path: RoutePath.payment.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: TuitionPaymentScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.paymentReceipt,
        path: RoutePath.paymentReceipt.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: PaymentReceiptScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.settings,
        path: RoutePath.settings.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(state: state, child: SettingsScreen());
        },
      ),
      GoRoute(
        name: RoutePath.changePassword,
        path: RoutePath.changePassword.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: ChangePasswordScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.children,
        path: RoutePath.children.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: MyChildrenScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.addChild,
        path: RoutePath.addChild.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(state: state, child: AddChildScreen());
        },
      ),

      GoRoute(
        name: RoutePath.editProfile,
        path: RoutePath.editProfile.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: EditProfileScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.childProfile,
        path: RoutePath.childProfile.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: ChildProfileScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.attendance,
        path: RoutePath.attendance.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: AttendanceScreen(),
          );
        },
      ),

      // -----------------------------------------------------
      // TEACHER
      // -----------------------------------------------------
      GoRoute(
        name: RoutePath.teacherSettings,
        path: RoutePath.teacherSettings.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: TeacherSettingsScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.teacherEditProfile,
        path: RoutePath.teacherEditProfile.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: EditTeacherProfileScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.teacherAttendance,
        path: RoutePath.teacherAttendance.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: TeacherAttendanceScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.teacherClassDetail,
        path: RoutePath.teacherClassDetail.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: TeacherClassDetailScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.teacherPostClassReport,
        path: RoutePath.teacherPostClassReport.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: TeacherPostClassReportScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.teacherReportSubmitted,
        path: RoutePath.teacherReportSubmitted.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: TeacherReportSubmittedScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.teacherEndClass,
        path: RoutePath.teacherEndClass.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: TeacherEndClassScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.teacherReportDetail,
        path: RoutePath.teacherReportDetail.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: TeacherReportDetailsScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.teacherStudentDetail,
        path: RoutePath.teacherStudentDetail.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: TeacherStudentDetailsScreen(),
          );
        },
      ),
    ],
  );

  static CustomTransitionPage _buildPageWithAnimation({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;

        final tween = Tween(begin: begin, end: end);

        final offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}

/*
1. Initial Routes
   └── Splash

2. Onboarding Routes
   ├── Choose Language
   ├── Choose Role
   ├── Onboarding
   └── Welcome

3. Authentication Routes
   ├── Login
   ├── Signup
   ├── Forgot Password
   ├── Reset Password
   ├── Active OTP
   └── Forgot OTP

4. Main Navigation
   └── Navigation Page

5. Profile Routes
   ├── Edit Profile
   ├── Completed Profile
   └── Completed Influencer Profile

6. Application Status
   ├── Submitted
   └── Under Review

7. Static Information
   ├── Claims
   ├── Help & Support
   ├── About
   ├── Privacy Policy
   └── Terms & Conditions

8. Account Settings
   ├── Subscription
   └── Change Password

9. Customer/Home Routes
   ├── Top Deals
   ├── Nearby
   ├── Category Merchants
   ├── Merchant Details
   ├── Offer Details
   └── Claimed Offer Details

10. Business Routes
   ├── Create Offer
   ├── Edit Offer
   ├── Business Info
   └── Alerts

11. Influencer Routes
   ├── Dashboard
   ├── Discover
   ├── Search
   ├── Tasks
   ├── Wallet
   ├── Campaign Details
   ├── Apply Campaign
   ├── My Campaigns
   ├── Submit Content
   ├── Your Submission
   └── Publish Proof

12. Common
   └── Success



*/
