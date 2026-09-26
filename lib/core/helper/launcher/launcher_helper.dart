import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/app_strings/app_strings.dart';
import '../toast/toast_helper.dart';

class LauncherHelper {
  /// Launches the phone dialer with the specified [phoneNumber].
  static Future<void> launchPhoneDialer(
    BuildContext context,
    String phoneNumber,
  ) async {
    final Uri dialUri = Uri(scheme: 'tel', path: phoneNumber);

    print('"phoneNumber  : $phoneNumber');

    try {
      if (await canLaunchUrl(dialUri)) {
        await launchUrl(dialUri);
      } else {
        if (context.mounted) {
          AppToast.info(
            context: context,
            message: AppStrings.dialerNotSupported,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.info(
          context: context,
          message: AppStrings.couldNotLaunchDialer,
        );
        print("Could not launch dialer: $e");
      }
    }
  }

  /// Launches WhatsApp with the specified [phoneNumber].
  static Future<void> launchWhatsApp(
    BuildContext context,
    String phoneNumber,
  ) async {
    // Clean the phone number of all non-numeric characters
    final cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final whatsAppUrl = Uri.parse("https://wa.me/$cleanPhoneNumber");
    try {
      // Launch directly without canLaunchUrl check because of package visibility restrictions on iOS/Android.
      final launched = await launchUrl(
        whatsAppUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        if (context.mounted) {
          AppToast.info(
            context: context,
            message: AppStrings.whatsappCannotBeOpened,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.info(
          context: context,
          message: AppStrings.couldNotLaunchWhatsapp,
        );
        print("Could not launch WhatsApp: $e");
      }
    }
  }
}
