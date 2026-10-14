import 'package:flutter/material.dart';

import '../../theme/app_dimensions.dart';

class AppLoader extends StatelessWidget {
  final double? size;
  final double? strokeWidth;
  final Color? color;

  const AppLoader({super.key, this.size, this.strokeWidth, this.color});

  @override
  Widget build(BuildContext context) {
    final loaderSize = size ?? AppDimensions.loaderSize;
    final loaderStrokeWidth = strokeWidth ?? AppDimensions.loaderStrokeWidth;

    return SizedBox(
      width: loaderSize,
      height: loaderSize,
      child: CircularProgressIndicator(
        strokeWidth: loaderStrokeWidth,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
