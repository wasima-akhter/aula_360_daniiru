import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

class AppSingleChildScrollView extends StatelessWidget {
  final Widget child;

  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final Axis scrollDirection;
  final ScrollPhysics? physics;

  const AppSingleChildScrollView({
    super.key,
    required this.child,
    this.padding,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      scrollDirection: scrollDirection,
      physics: physics,
      padding: padding ?? AppSpacing.screenPadding,
      child: child,
    );
  }
}
