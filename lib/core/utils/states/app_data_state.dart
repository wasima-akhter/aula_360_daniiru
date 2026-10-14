import 'package:flutter/material.dart';

import 'app_empty_widget.dart';
import 'app_error_widget.dart';
import 'app_loader.dart';
import 'app_no_connection.dart';

enum AppDataStatus {
  initial,
  loading,
  refreshing,
  loadingMore,
  success,
  empty,
  error,
  noConnection,
}

class AppDataState extends StatelessWidget {
  final AppDataStatus status;
  final Widget child;

  final Widget? loading;
  final Widget? empty;
  final Widget? error;
  final Widget? noConnection;
  final Widget? loadingMore;

  final VoidCallback? onRetry;

  const AppDataState({
    super.key,
    required this.status,
    required this.child,
    this.loading,
    this.empty,
    this.error,
    this.noConnection,
    this.loadingMore,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case AppDataStatus.initial:
      case AppDataStatus.loading:
        return loading ?? const Center(child: AppLoader());

      case AppDataStatus.empty:
        return empty ?? AppEmptyWidget(onRetry: onRetry);

      case AppDataStatus.error:
        return error ?? AppErrorWidget(onRetry: onRetry);

      case AppDataStatus.noConnection:
        return noConnection ?? AppNoConnection(onRetry: onRetry);

      case AppDataStatus.refreshing:
      case AppDataStatus.success:
      case AppDataStatus.loadingMore:
        return child;
    }
  }
}
