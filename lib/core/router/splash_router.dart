// import 'package:aula360/core/router/route_path.dart';
// import 'package:aula360/core/router/routes.dart';
// import 'package:flutter/material.dart';

// import '../../features/auth/core/service/auth_service.dart';
// import '../di/repo_service_injection.dart';
// import '../service/datasource/local/app_storage.dart';

// class SplashRouter {
//   static Future<void> navigate() async {
//     final storage = AppStorage.to;
//     final service = sl<AuthService>();

//     try {
//       // No authenticated session.
//       if (!storage.isLoggedIn || storage.accessToken.isEmpty) {
//         AppRouter.route.goNamed(RoutePath.loginScreen);
//         return;
//       }

//       final response = await service.me();

//       // Invalid / expired session.
//       if (!response.success || response.data == null) {
//         await storage.clearAuth();

//         AppRouter.route.goNamed(RoutePath.loginScreen);
//         return;
//       }

//       final user = response.data!;

//       // User is authenticated, but profile is incomplete.
//       // Splash should NOT send them to profile completion.
//       // They must log in again first.
//       if (!user.isProfileComplete) {
//         await storage.clearAuth();

//         AppRouter.route.goNamed(RoutePath.loginScreen);
//         return;
//       }

//       // Fully authenticated + profile complete.
//       AppRouter.route.goNamed(RoutePath.navigationPages);
//     } catch (e, s) {
//       debugPrint('SplashRouter Error: $e');
//       debugPrintStack(stackTrace: s);

//       await storage.clearAuth();

//       AppRouter.route.goNamed(RoutePath.loginScreen);
//     }
//   }
// }
