// // somewhere shared, e.g. core/router/role_router.dart
// import 'package:aula360/core/router/route_path.dart';
// import 'package:aula360/core/router/routes.dart';
// import 'package:flutter/material.dart';

// import '../di/repo_service_injection.dart';
// import '../service/datasource/local/app_storage.dart';

// class RoleRouter {
//   static Future<void> navigateByRole() async {
//     final service = sl<AuthService>();

//     try {
//       final response = await service.me();

//       if (!response.success || response.data == null) {
//         // ApiSnackbar.show(response.message, type: SnackbarType.error);

//         // Clear stale authentication state.
//         await AppStorage.to.clearAuth();

//         AppRouter.route.goNamed(RoutePath.chooseLanguageScreen);
//         return;
//       }

//       final user = response.data!;

//       if (!CommonController.to.setRole(
//         UserRoleExtension.fromString(user.role),
//       )) {
//         return;
//       }

//       if (!user.isActive) {
//         final resend = await service.resendOtp(
//           ResendOtpRequest(email: user.email),
//         );

//         if (!resend.success) {
//           ApiSnackbar.show(resend.message, type: SnackbarType.error);

//           return;
//         }

//         AppRouter.route.goNamed(RoutePath.activeOtpScreen, extra: user.email);

//         return;
//       }

//       if (!user.isProfileComplete) {
//         // Merchant still needs to complete business profile.
//         if (user.role == "MERCHANT" &&
//             user.sections.business?.complete == false) {
//           AppRouter.route.goNamed(RoutePath.completeBusinessProfileScreen);
//           return;
//         }

//         switch (user.role) {
//           case "MERCHANT":
//           case "USER":
//             AppRouter.route.goNamed(
//               RoutePath.completedProfileCustomerScreen,
//               extra: CompletedProfileCustomerArgs(
//                 email: user.email,
//                 role: user.role,
//               ),
//             );
//             return;

//           case "CREATOR":
//             AppRouter.route.goNamed(RoutePath.completedProfileInfluencerScreen);
//             return;

//           default:
//             ApiSnackbar.show(
//               "Unknown role ${user.role}",
//               type: SnackbarType.error,
//             );
//             return;
//         }
//       }

//       if (user.role == "MERCHANT" &&
//           user.sections.business?.complete == false) {
//         AppRouter.route.goNamed(RoutePath.completeBusinessProfileScreen);
//         return;
//       }

//       AppRouter.route.goNamed(RoutePath.navigationPages);
//     } catch (e, s) {
//       print('RoleRouter Error: $e');
//       debugPrintStack(stackTrace: s);

//       await AppStorage.to.clearAuth();

//       AppRouter.route.goNamed(RoutePath.chooseLanguageScreen);
//     }
//   }
// }
