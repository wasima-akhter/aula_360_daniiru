import 'package:aula360/features/share/widgets/loading/loading_widget.dart';

import '../../export/screen_export.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  final IconData? icon;

  final bool isOutlined;
  final Color? backgroundColor;

  // NEW
  final Color? outlineColor;
  final Color? foregroundColor;

  const CustomButton({
    required this.text,
    this.onTap,
    this.isLoading = false,
    this.icon,
    this.isOutlined = false,
    this.backgroundColor,
    this.outlineColor,
    this.foregroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor =
        outlineColor ??
        (isOutlined
            ? AppColors.primaryColor.withValues(alpha: 0.5)
            : Colors.transparent);

    final bgColor = isOutlined
        ? Colors.transparent
        : (backgroundColor ??
              (isDark ? AppColors.white : AppColors.primaryColor));

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: isOutlined
                ? Border.all(color: borderColor, width: 1.5)
                : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: buildChild(context),
        ),
      ),
    );
  }

  Widget buildChild(BuildContext context) {
    final textColor =
        foregroundColor ??
        (isOutlined ? AppColors.primaryColor : AppColors.white);

    if (isLoading) {
      return LoadingWidget(color: textColor);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
        ],
        Text(text, style: context.titleMedium.copyWith(color: textColor)),
      ],
    );
  }
}

class AulaPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Widget? trailing;

  final Color? textColor;

  const AulaPrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.trailing,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      // height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TxtStyle.titleSmall(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? AppColors.white,
                ),
              ),
            ),
            SizedBox(width: 6.w),
            trailing ?? Icon(Icons.arrow_forward_rounded, size: 18.sp),
          ],
        ),
      ),
    );
  }
}
