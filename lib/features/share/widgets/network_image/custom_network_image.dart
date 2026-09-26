import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../utils/api_urls/api_urls.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final Border? border;
  final BorderRadius? borderRadius;
  final BoxShape boxShape;
  final Color? backgroundColor;
  final Widget? child;
  final Widget? errorWidget;
  final ColorFilter? colorFilter;
  final BoxFit? fit;

  const CustomNetworkImage({
    super.key,
    this.child,
    this.errorWidget,
    this.colorFilter,
    required this.imageUrl,
    this.backgroundColor,
    this.height,
    this.width,
    this.border,
    this.borderRadius,
    this.fit,
    this.boxShape = BoxShape.rectangle,
  });

  bool get isSvg => imageUrl.toLowerCase().endsWith(".svg");

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: border,
          color: Colors.grey.withValues(alpha: 0.6),
          borderRadius: borderRadius,
          shape: boxShape,
        ),
        child: const Icon(Icons.error),
      );
    }

    if (isSvg) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          border: border,
          borderRadius: borderRadius,
          color: backgroundColor ?? Colors.grey.withValues(alpha: 0.2),
          shape: boxShape,
        ),
        child: SvgPicture.network(
          imageUrl,
          fit: fit ?? BoxFit.cover,
          colorFilter: colorFilter,
          placeholderBuilder: (context) => CircularProgressIndicator(),
          height: height,
          width: width,
        ),
      );
    }

    return CachedNetworkImage(
      // fake one:      "https://images.unsplash.com/photo-1606041008023-472dfb5e530f?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8Zmxvd2VyfGVufDB8fDB8fHww" ??
      imageUrl: getImageUrl(imageUrl, ApiUrls.base),
      fit: fit,
      imageBuilder: (context, imageProvider) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          border: border,
          borderRadius: borderRadius,
          shape: boxShape,
          color: backgroundColor,
          image: DecorationImage(
            image: imageProvider,
            fit: fit ?? BoxFit.cover,
            colorFilter: colorFilter,
          ),
        ),
        child: child,
      ),
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) {
        return _buildErrorWidget();
      },
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: border,
        color: Colors.grey.withValues(alpha: 0.6),
        borderRadius: borderRadius,
        shape: boxShape,
      ),
      child:
          errorWidget ??
          Icon(
            Icons.error,
            size: (height != null && height! < 40) ? (height! * 0.5) : null,
          ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        border: border,
        borderRadius: borderRadius,
        shape: boxShape,
        color: backgroundColor ?? Colors.grey.shade300,
      ),
      child: ClipRRect(
        borderRadius: boxShape == BoxShape.circle
            ? BorderRadius.circular(9999)
            : (borderRadius ?? BorderRadius.zero),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(color: Colors.white, child: child),
        ),
      ),
    );
  }
}

String getImageUrl(String? imageUrl, String baseUrl) {
  if (imageUrl == null || imageUrl.trim().isEmpty) {
    return '';
  }

  final url = imageUrl.trim();

  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }

  return '${baseUrl.replaceAll(RegExp(r'/$'), '')}/${url.replaceFirst(RegExp(r'^/'), '')}';
}
