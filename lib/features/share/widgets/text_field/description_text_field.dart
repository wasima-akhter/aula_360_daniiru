import 'package:aula360/utils/color/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DescriptionTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? contentPadding;
  final int maxLines;
  final Color? backgroundColor;
  final double? radius;
  final Function(String)? onChanged;

  const DescriptionTextField({
    super.key,
    this.controller,
    this.hintText = 'Text Here',
    this.hintStyle,
    this.textStyle,
    this.contentPadding,
    this.maxLines = 6,
    this.backgroundColor,
    this.radius = 10,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryContainer(
      radius: radius,
      color: backgroundColor ?? AppColors.background,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: textStyle ?? Theme.of(context).textTheme.bodyMedium,
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding:
              contentPadding ??
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hintText,
          hintStyle: hintStyle ?? Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class PrimaryContainer extends StatelessWidget {
  final Widget child;
  final double? radius;
  final Color? color;

  const PrimaryContainer({
    super.key,
    this.radius,
    this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular((radius ?? 30).r);

    return Container(
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surface,
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.backgroundsLinesColor, width: 1.w),
      ),
      child: ClipRRect(borderRadius: borderRadius, child: child),
    );
  }
}
