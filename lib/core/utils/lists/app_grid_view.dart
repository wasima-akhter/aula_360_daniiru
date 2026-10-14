import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import 'app_pagination_loader.dart';

class AppGridView extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  final int crossAxisCount;
  final double childAspectRatio;

  final double? mainAxisSpacing;
  final double? crossAxisSpacing;

  final EdgeInsetsGeometry? padding;

  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  final Future<void> Function()? onRefresh;

  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;

  final Widget? emptyWidget;

  const AppGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.padding,
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    this.onRefresh,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.emptyWidget,
  });

  @override
  State<AppGridView> createState() => _AppGridViewState();
}

class _AppGridViewState extends State<AppGridView> {
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

    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 300) {
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0 && widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }

    Widget grid = GridView.builder(
      controller: _controller,
      padding: widget.padding ?? AppSpacing.listPadding,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        childAspectRatio: widget.childAspectRatio,
        mainAxisSpacing: widget.mainAxisSpacing ?? AppSpacing.md,
        crossAxisSpacing: widget.crossAxisSpacing ?? AppSpacing.md,
      ),
      itemCount: widget.itemCount + (widget.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.itemCount) {
          return const AppPaginationLoader();
        }

        return widget.itemBuilder(context, index);
      },
    );

    if (widget.onRefresh != null) {
      grid = RefreshIndicator(onRefresh: widget.onRefresh!, child: grid);
    }

    return grid;
  }
}
