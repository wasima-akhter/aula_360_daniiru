import 'package:flutter/material.dart';

import '../../../../utils/enum/app_enum.dart';
import '../loading/loading_widget.dart';
import 'error_card.dart';
import 'no_data_card.dart';
import 'no_internet_card.dart';

class ApiSliverStatusBuilder extends StatelessWidget {
  final ApiStatus status;
  final String? errorMessage;
  final VoidCallback onRetry;

  /// Must return a sliver.
  final WidgetBuilder builder;

  final Widget? loadingWidget;
  final bool isLoadingMore;
  final bool hasMore;
  final Widget? noDataWidget;

  const ApiSliverStatusBuilder({
    super.key,
    required this.status,
    required this.onRetry,
    required this.builder,
    this.errorMessage,
    this.loadingWidget,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.noDataWidget,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ApiStatus.loading:
        return SliverFillRemaining(
          hasScrollBody: false,
          child: loadingWidget ?? const LoadingWidget(),
        );

      case ApiStatus.internetError:
        return SliverFillRemaining(
          hasScrollBody: false,
          child: NoInternetCard(onTap: onRetry),
        );

      case ApiStatus.error:
        return SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorCard(onTap: onRetry, message: errorMessage),
        );

      case ApiStatus.noDataFound:
        return SliverFillRemaining(
          hasScrollBody: false,
          child:
              noDataWidget ?? NoDataCard(onTap: onRetry, buttonText: 'Retry'),
        );

      case ApiStatus.completed:
        return SliverMainAxisGroup(
          slivers: [
            builder(context),

            if (hasMore && isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: LoadingWidget()),
                ),
              ),
          ],
        );
    }
  }
}
