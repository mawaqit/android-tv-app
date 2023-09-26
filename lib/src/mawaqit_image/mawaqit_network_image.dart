import 'package:flutter/material.dart';
import 'package:mawaqit/src/mawaqit_image/mawaqit_image_cache.dart';

class MawaqitNetworkImage extends Image {
  MawaqitNetworkImage({
    required String imageUrl,
    super.alignment,
    super.repeat,
    super.matchTextDirection = false,
    super.gaplessPlayback = false,
    super.excludeFromSemantics = false,
    super.semanticLabel,
    super.width,
    super.height,
    super.color,
    super.fit,
    super.centerSlice,
    super.colorBlendMode,
    super.filterQuality = FilterQuality.low,
    super.frameBuilder,
    super.loadingBuilder,
    super.errorBuilder = _defaultImageBuild,
    super.isAntiAlias = false,
    super.key,
    super.opacity,
  }) : super(image: MawaqitNetworkImageProvider(imageUrl));

  static Widget _defaultImageBuild(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return SizedBox.shrink();
  }
}
