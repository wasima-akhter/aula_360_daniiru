import 'package:aula360/features/share/widgets/loading/loading_widget.dart';
import 'package:aula360/utils/color/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../utils/extension/base_extension.dart' show ContextExtensions;

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

  const AulaPrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
            trailing ?? const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
