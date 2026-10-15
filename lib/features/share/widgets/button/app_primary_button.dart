import 'package:aula360/features/share/widgets/loading/loading_widget.dart';

import '../../export/screen_export.dart';

/// ============================================================================
/// CUSTOM BUTTON (RIVERPOD INTEGRATED)
/// ============================================================================
class CustomButton extends ConsumerWidget {
  final String text;
  final VoidCallback? onTap;
  final Future<void> Function()? onTapAsync;
  final bool isLoading;
  final bool Function(WidgetRef ref)? loadingSelector;
  final String? actionKey;
  final IconData? icon;

  final bool isOutlined;
  final Color? backgroundColor;
  final Color? outlineColor;
  final Color? foregroundColor;
  final double? height;
  final double? width;
  final double? borderRadius;
  final bool enabled;
  final Widget? loadingWidget;

  const CustomButton({
    required this.text,
    this.onTap,
    this.onTapAsync,
    this.isLoading = false,
    this.loadingSelector,
    this.actionKey,
    this.icon,
    this.isOutlined = false,
    this.backgroundColor,
    this.outlineColor,
    this.foregroundColor,
    this.height,
    this.width,
    this.borderRadius,
    this.enabled = true,
    this.loadingWidget,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActionLoading = actionKey != null
        ? ref.watch(buttonActionLoadingProvider(actionKey!))
        : false;
    final isSelectorLoading = loadingSelector != null
        ? loadingSelector!(ref)
        : false;
    final effectiveLoading = isLoading || isActionLoading || isSelectorLoading;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor =
        outlineColor ??
        (isOutlined
            ? AppColors.primaryColor.withValues(alpha: 0.5)
            : Colors.transparent);

    final baseBgColor = isOutlined
        ? Colors.transparent
        : (backgroundColor ??
              (isDark ? AppColors.white : AppColors.primaryColor));

    final effectiveBgColor = effectiveLoading || !enabled
        ? baseBgColor.withValues(alpha: isOutlined ? 0.3 : 0.65)
        : baseBgColor;

    final textColor =
        foregroundColor ??
        (isOutlined ? AppColors.primaryColor : AppColors.white);

    final VoidCallback? effectiveOnTap = (effectiveLoading || !enabled)
        ? null
        : () {
            if (onTapAsync != null) {
              final key = actionKey ?? text;
              ref
                  .read(buttonActionLoadingNotifierProvider.notifier)
                  .execute(key, onTapAsync!);
            } else if (onTap != null) {
              onTap!();
            }
          };

    return Material(
      color: effectiveBgColor,
      borderRadius: BorderRadius.circular(borderRadius ?? 16),
      child: InkWell(
        onTap: effectiveOnTap,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        child: Container(
          height: height ?? 48,
          width: width ?? double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: isOutlined
                ? Border.all(color: borderColor, width: 1.5)
                : null,
            borderRadius: BorderRadius.circular(borderRadius ?? 16),
          ),
          child: effectiveLoading
              ? (loadingWidget ?? LoadingWidget(color: textColor))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: textColor, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: context.titleMedium.copyWith(color: textColor),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// AULA PRIMARY BUTTON (RIVERPOD INTEGRATED)
/// ============================================================================
class AulaPrimaryButton extends ConsumerWidget {
  final String text;
  final VoidCallback? onTap;
  final Future<void> Function()? onTapAsync;
  final bool isLoading;
  final bool Function(WidgetRef ref)? loadingSelector;
  final String? actionKey;
  final Widget? trailing;
  final Widget? leading;
  final Color? textColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final double? borderRadius;
  final double? fontSize;
  final bool enabled;
  final Widget? loadingWidget;

  const AulaPrimaryButton({
    super.key,
    required this.text,
    this.onTap,
    this.onTapAsync,
    this.isLoading = false,
    this.loadingSelector,
    this.actionKey,
    this.trailing,
    this.leading,
    this.textColor,
    this.backgroundColor,
    this.height,
    this.width,
    this.borderRadius,
    this.fontSize,
    this.enabled = true,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActionLoading = actionKey != null
        ? ref.watch(buttonActionLoadingProvider(actionKey!))
        : false;
    final isSelectorLoading = loadingSelector != null
        ? loadingSelector!(ref)
        : false;
    final effectiveLoading = isLoading || isActionLoading || isSelectorLoading;

    final effectiveBgColor = backgroundColor ?? AppColors.primary;
    final effectiveTextColor = textColor ?? Colors.white;

    final VoidCallback? effectiveOnPressed = (effectiveLoading || !enabled)
        ? null
        : () {
            if (onTapAsync != null) {
              final key = actionKey ?? text;
              ref
                  .read(buttonActionLoadingNotifierProvider.notifier)
                  .execute(key, onTapAsync!);
            } else if (onTap != null) {
              onTap!();
            }
          };

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBgColor,
          foregroundColor: effectiveTextColor,
          disabledBackgroundColor: effectiveBgColor.withValues(alpha: 0.65),
          disabledForegroundColor: effectiveTextColor.withValues(alpha: 0.8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 7.r),
          ),
        ),
        child: effectiveLoading
            ? (loadingWidget ??
                  SizedBox(
                    height: 20.r,
                    width: 20.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        effectiveTextColor,
                      ),
                    ),
                  ))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[leading!, SizedBox(width: 6.w)],
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TxtStyle.titleSmall(
                        fontSize: fontSize ?? 17.sp,
                        fontWeight: FontWeight.w600,
                        color: effectiveTextColor,
                      ),
                    ),
                  ),
                  if (trailing != null || leading == null) ...[
                    SizedBox(width: 6.w),
                    trailing ?? Icon(Icons.arrow_forward_rounded, size: 18.sp),
                  ],
                ],
              ),
      ),
    );
  }
}
