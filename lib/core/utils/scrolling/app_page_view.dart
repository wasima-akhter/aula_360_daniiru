import 'package:flutter/material.dart';

class AppPageView extends StatelessWidget {
  final List<Widget> children;

  final PageController? controller;

  final Axis scrollDirection;
  final bool reverse;
  final bool allowImplicitScrolling;

  final ValueChanged<int>? onPageChanged;

  const AppPageView({
    super.key,
    required this.children,
    this.controller,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    this.allowImplicitScrolling = true,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: controller,
      scrollDirection: scrollDirection,
      reverse: reverse,
      allowImplicitScrolling: allowImplicitScrolling,
      onPageChanged: onPageChanged,
      children: children,
    );
  }
}
