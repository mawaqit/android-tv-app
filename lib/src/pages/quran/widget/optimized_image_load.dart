import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

class OptimizedCachedImage extends StatefulWidget {
  final String reciterId;
  final BoxFit fit;
  final String baseUrl;
  final Widget Function() offlineImageBuilder;

  const OptimizedCachedImage({
    Key? key,
    required this.reciterId,
    required this.fit,
    required this.baseUrl,
    required this.offlineImageBuilder,
  }) : super(key: key);

  @override
  State<OptimizedCachedImage> createState() => _OptimizedCachedImageState();
}

class _OptimizedCachedImageState extends State<OptimizedCachedImage> with AutomaticKeepAliveClientMixin {
  bool _isVisible = false;
  bool _shouldLoad = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100 * int.parse(widget.reciterId)), () {
      if (mounted) {
        setState(() {
          _shouldLoad = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return VisibilityDetector(
      key: Key('image-${widget.reciterId}'),
      onVisibilityChanged: (visibilityInfo) {
        final isVisible = visibilityInfo.visibleFraction > 0;
        if (_isVisible != isVisible) {
          setState(() {
            _isVisible = isVisible;
          });
        }
      },
      child: _shouldLoad && _isVisible
          ? FastCachedImage(
              url: '${widget.baseUrl}${widget.reciterId}.jpg',
              fit: widget.fit,
              fadeInDuration: const Duration(milliseconds: 300),
              loadingBuilder: (context, progress) => Container(
                color: Colors.transparent,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
              errorBuilder: (context, error, stackTrace) => widget.offlineImageBuilder(),
            )
          : Container(
              color: Colors.transparent,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
    );
  }
}
