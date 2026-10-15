import 'package:aula360/core/providers/button_loading_provider.dart';
import 'package:aula360/features/share/widgets/custom_text/custom_text.dart';
import 'package:aula360/utils/color/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CustomButtonExtra extends ConsumerWidget {
  const CustomButtonExtra({
    super.key,
    this.height = 55,
    this.width = double.maxFinite,
    this.onTap,
    this.onTapAsync,
    this.title = '',
    this.marginVertical = 0,
    this.marginHorizontal = 0,
    this.fillColor = AppColors.primaryColor,
    this.textColor = AppColors.white,
    this.isBorder = false,
    this.fontSize,
    this.borderWidth,
    this.borderRadius,
    this.isLoading = false,
    this.loadingSelector,
    this.actionKey,
    this.showIcon = false,
    this.iconSize = 20,
    this.borderColor,
    this.icon,
    this.fontWeight,
    this.enabled = true,
  });

  final Color? borderColor;
  final double height;
  final double? width;
  final Color? fillColor;
  final Color textColor;
  final VoidCallback? onTap;
  final Future<void> Function()? onTapAsync;
  final String title;
  final double marginVertical;
  final double marginHorizontal;
  final bool isBorder;
  final double? fontSize;
  final double? borderWidth;
  final double? borderRadius;
  final bool isLoading;
  final bool Function(WidgetRef ref)? loadingSelector;
  final String? actionKey;
  final bool showIcon;
  final double iconSize;
  final Widget? icon;
  final FontWeight? fontWeight;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActionLoading = actionKey != null
        ? ref.watch(buttonActionLoadingProvider(actionKey!))
        : false;
    final isSelectorLoading = loadingSelector != null
        ? loadingSelector!(ref)
        : false;
    final effectiveLoading = isLoading || isActionLoading || isSelectorLoading;

    final VoidCallback? effectiveOnTap = (effectiveLoading || !enabled)
        ? null
        : () {
            if (onTapAsync != null) {
              final key = actionKey ?? title;
              ref
                  .read(buttonActionLoadingNotifierProvider.notifier)
                  .execute(key, onTapAsync!);
            } else if (onTap != null) {
              onTap!();
            }
          };

    final effectiveBgColor = effectiveLoading || !enabled
        ? (fillColor ?? AppColors.primaryColor).withValues(alpha: 0.65)
        : (fillColor ?? AppColors.primaryColor);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: effectiveOnTap,
      child: Container(
        padding: const EdgeInsets.symmetric(),
        margin: EdgeInsets.symmetric(
          vertical: marginVertical,
          horizontal: marginHorizontal,
        ),
        alignment: Alignment.center,
        height: height,
        width: width,
        decoration: BoxDecoration(
          border: isBorder
              ? Border.all(
                  color: borderColor ?? Colors.black,
                  width: borderWidth ?? 2,
                )
              : null,
          borderRadius: BorderRadius.circular(borderRadius ?? 6),
          color: effectiveBgColor,
        ),
        child: effectiveLoading
            ? Center(
                child: SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: textColor,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    fontSize: fontSize ?? 19.5.sp,
                    fontWeight: fontWeight ?? FontWeight.w700,
                    color: textColor,
                    textAlign: TextAlign.center,
                    text: title,
                  ),
                  const Gap(8),
                  showIcon ? icon ?? const SizedBox() : const SizedBox.shrink(),
                ],
              ),
      ),
    );
  }
}

class DefaultProgressIndicator extends StatelessWidget {
  final Color? color;
  final double? strokeWidth;
  const DefaultProgressIndicator({super.key, this.color, this.strokeWidth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 15.w,
      width: 15.w,
      child: CircularProgressIndicator(
        color: color ?? AppColors.white,
        strokeWidth: strokeWidth ?? 2,
      ),
    );
  }
}
