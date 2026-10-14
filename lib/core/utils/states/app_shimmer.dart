import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_dimensions.dart';

class AppShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final double? borderRadius;
  final BorderRadiusGeometry? radius;

  const AppShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius =
        radius ?? BorderRadius.circular(borderRadius ?? AppDimensions.radiusMd);

    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: effectiveRadius,
        ),
      ),
    );
  }
}
