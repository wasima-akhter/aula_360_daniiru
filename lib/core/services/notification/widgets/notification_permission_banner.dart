import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../utils/app_strings/app_strings.dart';
import '../../../../utils/color/app_colors.dart';
import '../../../../utils/extension/language_extension.dart';
import '../push_notification_service.dart';

/// Contextual in-app banner for surfaces like the Notifications Tab or Dashboard.
///
/// Serves as a persistent / contextual **future opportunity** for users to
/// trigger the one-time OS system prompt after initially choosing "Maybe Later".
class NotificationPermissionBanner extends ConsumerStatefulWidget {
  const NotificationPermissionBanner({
    super.key,
    this.onPermissionChanged,
  });

  final VoidCallback? onPermissionChanged;

  @override
  ConsumerState<NotificationPermissionBanner> createState() =>
      _NotificationPermissionBannerState();
}

class _NotificationPermissionBannerState
    extends ConsumerState<NotificationPermissionBanner> {
  bool _isDismissedForSession = false;
  bool _hasPermission = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final pushService = ref.read(pushNotificationServiceProvider);
    final granted = await pushService.isPermissionGranted();
    if (mounted && granted != _hasPermission) {
      setState(() {
        _hasPermission = granted;
      });
    }
  }

  Future<void> _handleEnable() async {
    final pushService = ref.read(pushNotificationServiceProvider);
    final status = await pushService.getAuthorizationStatus();

    if (status == AuthorizationStatus.denied) {
      // OS prompt was already denied previously; open device settings
      if (!mounted) return;
      _showOpenSettingsDialog();
      return;
    }

    // Trigger one-time OS system dialog!
    final granted = await pushService.promptPermissionsFromPrimer();
    if (mounted) {
      setState(() {
        _hasPermission = granted;
      });
      widget.onPermissionChanged?.call();
    }
  }

  void _showOpenSettingsDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          ref.watchTr(AppStrings.notificationBannerTitle),
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.darkTextColor,
          ),
        ),
        content: Text(
          'Notifications are currently disabled in your device settings. Please allow notifications in system settings to receive updates.',
          style: TextStyle(fontSize: 13.5.sp, color: AppColors.subtitleTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(ref.watchTr(AppStrings.cancel)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await Geolocator.openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasPermission || _isDismissedForSession) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // soft blue
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              color: AppColors.primaryColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref.watchTr(AppStrings.notificationBannerTitle),
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTextColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  ref.watchTr(AppStrings.notificationBannerSubtitle),
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: AppColors.subtitleTextColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: _handleEnable,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              minimumSize: Size(0, 32.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              ref.watchTr(AppStrings.notificationBannerEnable),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, size: 16.sp, color: Colors.grey.shade600),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _isDismissedForSession = true;
              });
            },
          ),
        ],
      ),
    );
  }
}
