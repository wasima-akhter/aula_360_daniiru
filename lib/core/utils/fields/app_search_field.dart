import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_text_field.dart';

class AppSearchField extends StatelessWidget {
  final TextEditingController? controller;

  final String hint;

  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  final FocusNode? focusNode;

  final bool enabled;
  final bool readOnly;

  final bool showClearButton;

  final TextInputAction textInputAction;

  final EdgeInsetsGeometry? contentPadding;

  final double? borderRadius;

  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;

  final Widget? prefix;

  const AppSearchField({
    super.key,
    this.controller,
    this.hint = 'Search',
    this.onChanged,
    this.onTap,
    this.onClear,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.showClearButton = true,
    this.textInputAction = TextInputAction.search,
    this.contentPadding,
    this.borderRadius,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller ?? TextEditingController(),
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;

        return AppTextField(
          controller: controller,
          type: AppTextFieldType.text,
          hint: hint,
          onChanged: onChanged,
          onTap: onTap,
          focusNode: focusNode,
          enabled: enabled,
          readOnly: readOnly,
          textInputAction: textInputAction,
          prefix: prefix ?? Icon(Icons.search, size: 20.sp),
          suffix: showClearButton && hasText
              ? IconButton(
                  onPressed: () {
                    controller?.clear();
                    onClear?.call();
                    onChanged?.call('');
                  },
                  icon: Icon(Icons.close, size: 20.sp),
                )
              : null,
          contentPadding:
              contentPadding ??
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          borderRadius: borderRadius ?? 12.r,
          fillColor: fillColor,
          borderColor: borderColor,
          focusedBorderColor: focusedBorderColor,
        );
      },
    );
  }
}
