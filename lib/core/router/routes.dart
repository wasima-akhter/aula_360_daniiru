import 'package:aula360/features/auth/presentation/parent_auth/profile_setup_screen.dart';
import 'package:aula360/features/auth/presentation/teacher_auth/teacher_login_screen.dart';
import 'package:aula360/features/auth/presentation/teacher_auth/teacher_sign_up_screen.dart';
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
      // =====================================================
      // GoRoute(
      //   name: RoutePath.navigationPages,
      //   path: RoutePath.navigationPages.addBasePath,
      //   pageBuilder: (context, state) {
      //     return _buildPageWithAnimation(
      //       state: state,
      //       child: const NavigationPage(),
      //     );
      //   },
      // ),
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
        name: RoutePath.profileScreen,
        path: RoutePath.profileScreen.addBasePath,
        pageBuilder: (context, state) {
          return _buildPageWithAnimation(
            state: state,
            child: ProfileSetupScreen(),
          );
        },
      ),
      GoRoute(
        name: RoutePath.teacherProfileScreen,
        path: RoutePath.teacherProfileScreen.addBasePath,
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
