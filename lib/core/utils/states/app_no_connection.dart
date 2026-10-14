import 'package:flutter/material.dart';

import '../../theme/app_dimensions.dart';
import '../../theme/app_spacing.dart';

class AppNoConnection extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final String retryText;
  final IconData icon;

  const AppNoConnection({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.retryText = 'Try Again',
    this.icon = Icons.wifi_off_rounded,
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
              size: AppDimensions.emptyIconSize,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              title ?? 'No internet connection',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              message ?? 'Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
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
