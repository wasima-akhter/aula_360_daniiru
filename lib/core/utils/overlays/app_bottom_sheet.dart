import 'package:flutter/material.dart';

import '../../theme/app_dimensions.dart';
import '../../theme/app_spacing.dart';

class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;

  final bool showHandle;
  final EdgeInsetsGeometry? padding;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showHandle = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: padding ?? AppSpacing.bottomSheetPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showHandle)
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            if (showHandle) SizedBox(height: AppSpacing.md),
            if (title != null) ...[
              Text(title!, style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: AppSpacing.lg),
            ],
            child,
          ],
        ),
      ),
    );
  }

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    bool showHandle = true,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      builder: (_) =>
          AppBottomSheet(title: title, showHandle: showHandle, child: child),
    );
  }
}
