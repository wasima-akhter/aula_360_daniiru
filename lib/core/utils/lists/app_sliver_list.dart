import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import 'app_pagination_loader.dart';

class AppSliverList extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  final EdgeInsetsGeometry? padding;

  final bool isLoadingMore;

  final Widget? separator;

  const AppSliverList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.isLoadingMore = false,
    this.separator,
  });

  @override
  Widget build(BuildContext context) {
    final totalCount = itemCount + (isLoadingMore ? 1 : 0);

    return SliverPadding(
      padding: padding ?? AppSpacing.listPadding,
      sliver: SliverList.separated(
        itemCount: totalCount,
        separatorBuilder: (_, index) {
          if (index >= itemCount - 1) {
            return const SizedBox.shrink();
          }

          return separator ?? SizedBox(height: AppSpacing.md);
        },
        itemBuilder: (context, index) {
          if (index >= itemCount) {
            return const AppPaginationLoader();
          }

          return itemBuilder(context, index);
        },
      ),
    );
  }
}
