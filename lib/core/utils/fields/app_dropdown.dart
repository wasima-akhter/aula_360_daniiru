import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;

  final String? label;
  final String? hint;

  final ValueChanged<T?>? onChanged;

  final String Function(T item)? itemLabelBuilder;

  final String? Function(T?)? validator;

  final bool enabled;
  final bool isExpanded;

  final Widget? prefix;
  final IconData? prefixIcon;

  final Widget? suffixIcon;

  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;

  final EdgeInsetsGeometry? contentPadding;

  final double? borderRadius;

  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;

  final bool filled;

  const AppDropdown({
    super.key,
    this.value,
    required this.items,
    this.label,
    this.hint,
    this.onChanged,
    this.itemLabelBuilder,
    this.validator,
    this.enabled = true,
    this.isExpanded = true,
    this.prefix,
    this.prefixIcon,
    this.suffixIcon,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.contentPadding,
    this.borderRadius,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.filled = true,
  });

  String _itemLabel(T item) {
    if (itemLabelBuilder != null) {
      return itemLabelBuilder!(item);
    }

    return item.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final radius = BorderRadius.circular((borderRadius ?? 12).r);

    final effectiveBorderColor =
        borderColor ?? colorScheme.outline.withValues(alpha: 0.5);

    final effectiveFocusedBorderColor =
        focusedBorderColor ?? colorScheme.primary;

    final effectiveErrorBorderColor = errorBorderColor ?? colorScheme.error;

    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            _itemLabel(item),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                textStyle ??
                theme.textTheme.bodyMedium?.copyWith(fontSize: 15.sp),
          ),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: isExpanded,
      icon: suffixIcon ?? Icon(Icons.keyboard_arrow_down_rounded, size: 22.sp),
      style:
          textStyle ??
          theme.textTheme.bodyMedium?.copyWith(
            fontSize: 15.sp,
            color: colorScheme.onSurface,
          ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: labelStyle ?? theme.inputDecorationTheme.labelStyle,
        hintStyle: hintStyle ?? theme.inputDecorationTheme.hintStyle,
        filled: filled,
        fillColor: fillColor ?? theme.inputDecorationTheme.fillColor,
        prefixIcon:
            prefix ??
            (prefixIcon != null ? Icon(prefixIcon, size: 20.sp) : null),
        contentPadding:
            contentPadding ??
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: effectiveBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: effectiveBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: effectiveFocusedBorderColor,
            width: 1.5.w,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: effectiveErrorBorderColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: effectiveErrorBorderColor,
            width: 1.5.w,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: effectiveBorderColor.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
