import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

class AppDialog extends StatelessWidget {
  final String? title;
  final String? message;

  final Widget? content;
  final List<Widget>? actions;

  const AppDialog({
    super.key,
    this.title,
    this.message,
    this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title != null ? Text(title!) : null,
      content: content ?? (message != null ? Text(message!) : null),
      actionsPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      actions: actions,
    );
  }

  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    String? message,
    Widget? content,
    List<Widget>? actions,
  }) {
    return showDialog<T>(
      context: context,
      builder: (_) => AppDialog(
        title: title,
        message: message,
        content: content,
        actions: actions,
      ),
    );
  }
}
