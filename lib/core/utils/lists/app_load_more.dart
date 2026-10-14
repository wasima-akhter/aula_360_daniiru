import 'package:flutter/material.dart';

import 'app_pagination_loader.dart';

class AppLoadMore extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool hasMore;

  final String text;
  final String loadingText;

  const AppLoadMore({
    super.key,
    required this.onPressed,
    required this.hasMore,
    this.isLoading = false,
    this.text = 'Load More',
    this.loadingText = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    if (!hasMore) {
      return const SizedBox.shrink();
    }

    if (isLoading) {
      return const AppPaginationLoader();
    }

    return Center(
      child: ElevatedButton(onPressed: onPressed, child: Text(text)),
    );
  }
}
