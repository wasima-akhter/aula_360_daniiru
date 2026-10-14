import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/app_dimensions.dart';

class AppCachedImage extends StatelessWidget {
  final String? url;

  final double? width;
  final double? height;

  final BoxFit fit;
  final BorderRadiusGeometry? borderRadius;

  final Widget? placeholder;
  final Widget? errorWidget;

  const AppCachedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final radius =
        borderRadius ?? BorderRadius.circular(AppDimensions.radiusMd);

    if (url == null || url!.trim().isEmpty) {
      return _buildError(radius);
    }

    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, _) => placeholder ?? _buildPlaceholder(),
        errorWidget: (_, _, _) => errorWidget ?? _buildErrorContent(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return SizedBox(
      width: width,
      height: height,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError(BorderRadiusGeometry radius) {
    return ClipRRect(borderRadius: radius, child: _buildErrorContent());
  }

  Widget _buildErrorContent() {
    return SizedBox(
      width: width,
      height: height,
      child: const Center(child: Icon(Icons.image_not_supported_outlined)),
    );
  }
}
