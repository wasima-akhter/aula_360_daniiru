import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/color/app_colors.dart';

/// Interactive heads-up notification card displayed while the app is in foreground.
class InAppNotificationOverlay {
  static OverlayEntry? _activeEntry;
  static Timer? _autoDismissTimer;

  /// Displays a floating notification banner from the top of the screen.
  static void show({
    required OverlayState overlayState,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    VoidCallback? onTap,
    Duration displayDuration = const Duration(seconds: 4),
  }) {
    dismiss();

    _activeEntry = OverlayEntry(
      builder: (context) => _InAppNotificationWidget(
        title: title,
        body: body,
        data: data ?? const {},
        onTap: () {
          dismiss();
          onTap?.call();
        },
        onDismiss: dismiss,
      ),
    );

    overlayState.insert(_activeEntry!);

    _autoDismissTimer = Timer(displayDuration, () {
      dismiss();
    });
  }

  /// Dismisses any active foreground notification banner.
  static void dismiss() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    _activeEntry?.remove();
    _activeEntry = null;
  }
}

class _InAppNotificationWidget extends StatefulWidget {
  const _InAppNotificationWidget({
    required this.title,
    required this.body,
    required this.data,
    required this.onTap,
    required this.onDismiss,
  });

  final String title;
  final String body;
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  State<_InAppNotificationWidget> createState() =>
      _InAppNotificationWidgetState();
}

class _InAppNotificationWidgetState extends State<_InAppNotificationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleDismiss() async {
    await _animController.reverse();
    widget.onDismiss();
  }

  IconData _resolveIcon(String type) {
    switch (type.toUpperCase()) {
      case 'CHAT':
      case 'CONVERSATION':
      case 'MESSAGE':
        return Icons.chat_bubble_outline_rounded;
      case 'ANNOUNCEMENT':
      case 'NOTICE':
        return Icons.campaign_rounded;
      case 'ATTENDANCE':
        return Icons.fact_check_outlined;
      case 'REPORT':
        return Icons.assessment_outlined;
      case 'HOMEWORK':
        return Icons.assignment_outlined;
      case 'PAYMENT':
        return Icons.payment_rounded;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Color _resolveIconBg(String type) {
    switch (type.toUpperCase()) {
      case 'CHAT':
      case 'CONVERSATION':
      case 'MESSAGE':
        return const Color(0xFF6366F1); // Indigo
      case 'ANNOUNCEMENT':
      case 'NOTICE':
        return const Color(0xFFF59E0B); // Amber
      case 'ATTENDANCE':
        return const Color(0xFF10B981); // Emerald
      case 'REPORT':
        return const Color(0xFF8B5CF6); // Purple
      case 'HOMEWORK':
        return const Color(0xFF3B82F6); // Blue
      case 'PAYMENT':
        return const Color(0xFF14B8A6); // Teal
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type =
        widget.data['type']?.toString() ??
        widget.data['click_action']?.toString() ??
        '';
    final iconBg = _resolveIconBg(type);
    final iconData = _resolveIcon(type);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8.h,
      left: 14.w,
      right: 14.w,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onTap,
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta != null && details.primaryDelta! < -4) {
                  _handleDismiss();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: iconBg.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(iconData, color: iconBg, size: 20.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          if (widget.body.isNotEmpty) ...[
                            SizedBox(height: 2.h),
                            Text(
                              widget.body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.subtitleTextColor,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18.sp,
                        color: Colors.grey.shade400,
                      ),
                      onPressed: _handleDismiss,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
