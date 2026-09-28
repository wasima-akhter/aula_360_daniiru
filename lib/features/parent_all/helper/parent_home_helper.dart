import 'package:aula360/utils/color/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

// ================================================================
// MODELS
// ================================================================

class ClassModel {
  final String subject;
  final String teacher;
  final String time;
  final String duration;
  final String room;
  final String building;
  final String category;
  final Color color;

  const ClassModel({
    required this.subject,
    required this.teacher,
    required this.time,
    required this.duration,
    required this.room,
    required this.building,
    required this.category,
    required this.color,
  });
}

// ================================================================
// COMMON APP BAR
// ================================================================

class AulaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  const AulaAppBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.actions,
    this.onBack,
  });

  @override
  Size get preferredSize => Size.fromHeight(58.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      centerTitle: false,
      automaticallyImplyLeading: false,
      titleSpacing: 18.w,
      leading: showBack
          ? IconButton(
              onPressed: onBack ?? () => context.pop(),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 19.sp,
                color: AppColors.text,
              ),
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.text,
          fontSize: 19.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(height: 1.h, color: AppColors.backgroundsLinesColor),
      ),
    );
  }
}

// ================================================================
// COMMON SECTION TITLE
// ================================================================

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText!,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

// ================================================================
// COMMON CARD
// ================================================================

class AulaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double radius;

  const AulaCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(radius.r),
        border: Border.all(color: AppColors.backgroundsLinesColor, width: 1.w),
      ),
      child: child,
    );
  }
}

// ================================================================
// AVATAR
// ================================================================

class UserAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    required this.initials,
    this.size = 42,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFE9EEFF),
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: (size * .30).sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ================================================================
// STATUS PILL
// ================================================================

class StatusPill extends StatelessWidget {
  final String text;
  final Color color;

  const StatusPill({
    super.key,
    required this.text,
    this.color = const Color(0xFF14B87A),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 5.w),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
