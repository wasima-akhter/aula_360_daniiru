import '../../share/export/screen_export.dart';

export '../domain/models/parent_models.dart';

class AulaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;
  final Widget? leading;
  final double? leadingWidth;

  const AulaAppBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.actions,
    this.leading,
    this.leadingWidth,
  });

  @override
  Size get preferredSize => const Size.fromHeight(62);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,

      leadingWidth:
          leadingWidth ??
          (leading != null
              ? 135
              : showBack
              ? 52
              : null),

      leading:
          leading ??
          (showBack
              ? IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.primaryDark,
                    size: 24,
                  ),
                )
              : null),

      title: title.isEmpty
          ? null
          : Text(
              title,
              style: TxtStyle.titleLarge(
                color: AppColors.text,
                fontSize: 18.5,
                fontWeight: FontWeight.w700,
              ),
            ),

      actions: actions,

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.backgroundsLinesColor),
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
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText!,
              style: TxtStyle.titleLarge(
                color: AppColors.primary,
                fontSize: 15.sp,
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
        style: TxtStyle.titleLarge(
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
            style: TxtStyle.titleLarge(
              color: color,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
