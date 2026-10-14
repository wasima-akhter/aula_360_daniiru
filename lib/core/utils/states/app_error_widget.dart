import 'package:flutter/material.dart';

import '../../theme/app_dimensions.dart';
import '../../theme/app_spacing.dart';

class AppErrorWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final String retryText;
  final IconData icon;

  const AppErrorWidget({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.retryText = 'Retry',
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppDimensions.errorIconSize,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              title ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (message != null) ...[
              SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (onRetry != null) ...[
              SizedBox(height: AppSpacing.lg),
              FilledButton(onPressed: onRetry, child: Text(retryText)),
            ],
          ],
        ),
      ),
    );
  }
}
