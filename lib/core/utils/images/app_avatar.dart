import 'package:flutter/material.dart';

import 'app_cached_image.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;

  final Widget? fallback;
  final Color? backgroundColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.radius = 24,
    this.fallback,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;

    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor:
            backgroundColor ??
            Theme.of(context).colorScheme.surfaceContainerHighest,
        child: fallback ?? Icon(Icons.person_outline, size: radius),
      );
    }

    return ClipOval(
      child: AppCachedImage(
        url: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.zero,
      ),
    );
  }
}
