import 'package:flutter/material.dart';

import '../../theme/app_dimensions.dart';
import '../../theme/app_spacing.dart';

class AppEmptyWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData icon;
  final Widget? action;

  final VoidCallback? onRetry;

  const AppEmptyWidget({
    super.key,
    this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.onRetry,
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
              title ?? 'Nothing here yet',
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

            // onRetry button add
            if (onRetry != null) ...[
              SizedBox(height: AppSpacing.lg),
              FilledButton(onPressed: onRetry, child: Text('Retry')),
            ],

            if (action != null) ...[SizedBox(height: AppSpacing.lg), action!],
          ],
        ),
      ),
    );
  }
}
