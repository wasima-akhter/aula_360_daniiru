import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import 'app_pagination_loader.dart';

class AppListView extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  final EdgeInsetsGeometry? padding;

  final double? itemExtent;
  final ScrollController? controller;

  final ScrollPhysics? physics;
  final bool shrinkWrap;

  final Future<void> Function()? onRefresh;

  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;

  final Widget? separator;
  final Widget? emptyWidget;

  const AppListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.itemExtent,
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    this.onRefresh,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.separator,
    this.emptyWidget,
  });

  @override
  State<AppListView> createState() => _AppListViewState();
}

class _AppListViewState extends State<AppListView> {
  late final ScrollController _controller;

  bool get _ownsController => widget.controller == null;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? ScrollController();
    _controller.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleScroll);

    if (_ownsController) {
      _controller.dispose();
    }

    super.dispose();
  }

  void _handleScroll() {
    if (widget.onLoadMore == null ||
        !widget.hasMore ||
        widget.isLoadingMore ||
        !_controller.hasClients) {
      return;
    }

    final position = _controller.position;

    if (position.pixels >= position.maxScrollExtent - 300) {
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0 && widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }

    Widget list = ListView.separated(
      controller: _controller,
      padding: widget.padding ?? AppSpacing.listPadding,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      itemCount: widget.itemCount + (widget.isLoadingMore ? 1 : 0),

      separatorBuilder: (_, index) {
        if (index >= widget.itemCount - 1) {
          return const SizedBox.shrink();
        }

        return widget.separator ?? SizedBox(height: AppSpacing.md);
      },
      itemBuilder: (context, index) {
        if (index >= widget.itemCount) {
          return const AppPaginationLoader();
        }

        return widget.itemBuilder(context, index);
      },
    );

    if (widget.onRefresh != null) {
      list = RefreshIndicator(onRefresh: widget.onRefresh!, child: list);
    }

    return list;
  }
}
