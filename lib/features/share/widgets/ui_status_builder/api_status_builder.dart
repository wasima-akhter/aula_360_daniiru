import 'package:flutter/material.dart';

import '../../../../utils/enum/app_enum.dart';
import '../loading/loading_widget.dart';
import 'error_card.dart';
import 'no_data_card.dart';
import 'no_internet_card.dart';

class ApiStatusBuilder extends StatelessWidget {
  final ApiStatus status;
  final String? errorMessage;
  final VoidCallback onRetry;
  final WidgetBuilder builder;

  /// Custom loading widget
  final Widget? loadingWidget;

  /// Custom error widget
  final Widget? errorWidget;

  /// Custom no-data widget
  final Widget? noDataWidget;

  /// Pagination
  final bool isLoadingMore;
  final bool hasMore;

  const ApiStatusBuilder({
    super.key,
    required this.status,
    required this.onRetry,
    required this.builder,
    this.errorMessage,
    this.loadingWidget,
    this.errorWidget,
    this.noDataWidget,
    this.isLoadingMore = false,
    this.hasMore = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ApiStatus.loading:
        return loadingWidget ?? const LoadingWidget();

      case ApiStatus.internetError:
        return NoInternetCard(onTap: onRetry);

      case ApiStatus.error:
        return errorWidget ?? ErrorCard(onTap: onRetry, message: errorMessage);

      case ApiStatus.noDataFound:
        return noDataWidget ?? NoDataCard(onTap: onRetry, buttonText: 'Retry');

      case ApiStatus.completed:
        return SingleChildScrollView(
          child: Column(
            children: [
              builder(context),

              if (hasMore && isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: LoadingWidget()),
                ),
            ],
          ),
        );
    }
  }
}
