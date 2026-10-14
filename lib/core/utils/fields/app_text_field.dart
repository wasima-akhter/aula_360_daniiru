import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum AppTextFieldType { text, name, phone, email, description, password }

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final AppTextFieldType type;

  final String? label;
  final String? hint;

  final String? Function(String?)? validator;

  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;

  final FocusNode? focusNode;

  final bool enabled;
  final bool readOnly;

  final Widget? prefix;
  final IconData? prefixIcon;

  final Widget? suffix;
  final IconData? suffixIcon;

  final int? maxLength;
  final int? maxLines;
  final int minLines;

  final TextInputAction? textInputAction;

  final List<TextInputFormatter>? inputFormatters;

  final TextCapitalization? textCapitalization;

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

  const AppTextField({
    super.key,
    this.controller,
    this.type = AppTextFieldType.text,
    this.label,
    this.hint,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.prefix,
    this.prefixIcon,
    this.suffix,
    this.suffixIcon,
    this.maxLength,
    this.maxLines,
    this.minLines = 1,
    this.textInputAction,
    this.inputFormatters,
    this.textCapitalization,
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

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = false;

  bool get _isPassword => widget.type == AppTextFieldType.password;

  @override
  void initState() {
    super.initState();
    _obscureText = _isPassword;
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.type != widget.type) {
      _obscureText = _isPassword;
    }
  }

  TextInputType get _keyboardType {
    switch (widget.type) {
      case AppTextFieldType.phone:
        return TextInputType.phone;

      case AppTextFieldType.email:
        return TextInputType.emailAddress;

      case AppTextFieldType.description:
        return TextInputType.multiline;

      case AppTextFieldType.password:
        return TextInputType.visiblePassword;

      case AppTextFieldType.name:
      case AppTextFieldType.text:
        return TextInputType.text;
    }
  }

  TextInputAction get _textInputAction {
    if (widget.textInputAction != null) {
      return widget.textInputAction!;
    }

    if (widget.type == AppTextFieldType.description) {
      return TextInputAction.newline;
    }

    return TextInputAction.next;
  }

  int get _maxLines {
    if (widget.maxLines != null) {
      return widget.maxLines!;
    }

    if (widget.type == AppTextFieldType.description) {
      return 5;
    }

    return 1;
  }

  TextCapitalization get _textCapitalization {
    if (widget.textCapitalization != null) {
      return widget.textCapitalization!;
    }

    switch (widget.type) {
      case AppTextFieldType.name:
        return TextCapitalization.words;

      case AppTextFieldType.description:
        return TextCapitalization.sentences;

      default:
        return TextCapitalization.none;
    }
  }

  List<TextInputFormatter>? get _inputFormatters {
    if (widget.inputFormatters != null) {
      return widget.inputFormatters;
    }

    switch (widget.type) {
      case AppTextFieldType.phone:
        return [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]'))];

      case AppTextFieldType.name:
        return [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZÀ-ÿ\s'-]"))];

      default:
        return null;
    }
  }

  Widget? _buildSuffixIcon(BuildContext context) {
    if (_isPassword) {
      return IconButton(
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          size: 20.sp,
        ),
      );
    }

    return widget.suffix ??
        (widget.suffixIcon != null
            ? Icon(widget.suffixIcon, size: 20.sp)
            : null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final radius = BorderRadius.circular((widget.borderRadius ?? 12).r);

    final defaultBorderColor =
        widget.borderColor ?? colorScheme.outline.withValues(alpha: 0.5);

    final effectiveFocusedBorderColor =
        widget.focusedBorderColor ?? colorScheme.primary;

    final effectiveErrorBorderColor =
        widget.errorBorderColor ?? colorScheme.error;

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      keyboardType: _keyboardType,
      textInputAction: _textInputAction,
      textCapitalization: _textCapitalization,
      obscureText: _isPassword && _obscureText,
      maxLines: _maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      onFieldSubmitted: widget.onSubmitted,
      inputFormatters: _inputFormatters,
      style:
          widget.textStyle ??
          theme.textTheme.bodyMedium?.copyWith(fontSize: 15.sp),
      cursorColor: colorScheme.primary,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        labelStyle: widget.labelStyle ?? theme.inputDecorationTheme.labelStyle,
        hintStyle: widget.hintStyle ?? theme.inputDecorationTheme.hintStyle,
        filled: widget.filled,
        fillColor: widget.fillColor ?? theme.inputDecorationTheme.fillColor,
        prefixIcon:
            widget.prefix ??
            (widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 20.sp)
                : null),
        suffixIcon: _buildSuffixIcon(context),
        contentPadding:
            widget.contentPadding ??
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: defaultBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: defaultBorderColor),
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
            color: defaultBorderColor.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
