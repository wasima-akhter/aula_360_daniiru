// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/Poppins-Bold.ttf
  String get poppinsBold => 'assets/fonts/Poppins-Bold.ttf';

  /// File path: assets/fonts/Poppins-ExtraBold.ttf
  String get poppinsExtraBold => 'assets/fonts/Poppins-ExtraBold.ttf';

  /// File path: assets/fonts/Poppins-Medium.ttf
  String get poppinsMedium => 'assets/fonts/Poppins-Medium.ttf';

  /// File path: assets/fonts/Poppins-Regular.ttf
  String get poppinsRegular => 'assets/fonts/Poppins-Regular.ttf';

  /// File path: assets/fonts/Poppins-SemiBold.ttf
  String get poppinsSemiBold => 'assets/fonts/Poppins-SemiBold.ttf';

  /// List of all assets
  List<String> get values => [
    poppinsBold,
    poppinsExtraBold,
    poppinsMedium,
    poppinsRegular,
    poppinsSemiBold,
  ];
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/heart_icon.svg
  SvgGenImage get heartIcon => const SvgGenImage('assets/icons/heart_icon.svg');

  /// File path: assets/icons/splash.svg
  SvgGenImage get splash => const SvgGenImage('assets/icons/splash.svg');

  /// File path: assets/icons/successfull_icon.svg
  SvgGenImage get successfullIcon =>
      const SvgGenImage('assets/icons/successfull_icon.svg');

  /// File path: assets/icons/whatsapps.svg
  SvgGenImage get whatsapps => const SvgGenImage('assets/icons/whatsapps.svg');

  /// List of all assets
  List<SvgGenImage> get values => [
    heartIcon,
    splash,
    successfullIcon,
    whatsapps,
  ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/foodimge.webp
  AssetGenImage get foodimge =>
      const AssetGenImage('assets/images/foodimge.webp');

  /// File path: assets/images/influencer_onboard_one.webp
  AssetGenImage get influencerOnboardOne =>
      const AssetGenImage('assets/images/influencer_onboard_one.webp');

  /// File path: assets/images/influencer_onboard_three.webp
  AssetGenImage get influencerOnboardThree =>
      const AssetGenImage('assets/images/influencer_onboard_three.webp');

  /// File path: assets/images/influencer_onboard_two.webp
  AssetGenImage get influencerOnboardTwo =>
      const AssetGenImage('assets/images/influencer_onboard_two.webp');

  /// File path: assets/images/onboardone.webp
  AssetGenImage get onboardone =>
      const AssetGenImage('assets/images/onboardone.webp');

  /// File path: assets/images/onboardthree.webp
  AssetGenImage get onboardthree =>
      const AssetGenImage('assets/images/onboardthree.webp');

  /// File path: assets/images/onboardtwo.webp
  AssetGenImage get onboardtwo =>
      const AssetGenImage('assets/images/onboardtwo.webp');

  /// File path: assets/images/splashlogo.webp
  AssetGenImage get splashlogo =>
      const AssetGenImage('assets/images/splashlogo.webp');

  /// List of all assets
  List<AssetGenImage> get values => [
    foodimge,
    influencerOnboardOne,
    influencerOnboardThree,
    influencerOnboardTwo,
    onboardone,
    onboardthree,
    onboardtwo,
    splashlogo,
  ];
}

class $AssetsLanguagesGen {
  const $AssetsLanguagesGen();

  /// File path: assets/languages/ar.json
  String get ar => 'assets/languages/ar.json';

  /// File path: assets/languages/de.json
  String get de => 'assets/languages/de.json';

  /// File path: assets/languages/en.json
  String get en => 'assets/languages/en.json';

  /// File path: assets/languages/es.json
  String get es => 'assets/languages/es.json';

  /// File path: assets/languages/fr.json
  String get fr => 'assets/languages/fr.json';

  /// File path: assets/languages/it.json
  String get it => 'assets/languages/it.json';

  /// File path: assets/languages/ja.json
  String get ja => 'assets/languages/ja.json';

  /// File path: assets/languages/so.json
  String get so => 'assets/languages/so.json';

  /// File path: assets/languages/zh.json
  String get zh => 'assets/languages/zh.json';

  /// List of all assets
  List<String> get values => [ar, de, en, es, fr, it, ja, so, zh];
}

class Assets {
  const Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsLanguagesGen languages = $AssetsLanguagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}

class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = false;

  const SvgGenImage.vec(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    _svg.ColorMapper? colorMapper,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
        colorMapper: colorMapper,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter:
          colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
