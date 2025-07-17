import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/src/mawaqit_image/mawaqit_cache.dart';
import 'package:mawaqit/main.dart';

class MawaqitNetworkImageProvider extends ImageProvider<NetworkImage> implements NetworkImage {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments [url] and [scale] must not be null.
  const MawaqitNetworkImageProvider(
    this.url, {
    this.scale = 1.0,
    this.headers,
    this.onError,
  });

  @override
  final String url;

  @override
  final double scale;

  @override
  final Map<String, String>? headers;

  final VoidCallback? onError;

  @override
  Future<NetworkImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NetworkImage>(this);
  }

  @override
  ImageStreamCompleter loadBuffer(NetworkImage key, DecoderBufferCallback decode) {
    final chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key as MawaqitNetworkImageProvider, chunkEvents, decode),
      scale: scale,
      chunkEvents: chunkEvents.stream,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<NetworkImage>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
    MawaqitNetworkImageProvider key,
    StreamController<ImageChunkEvent> chunkEvents,
    DecoderBufferCallback decode,
  ) async {
    try {
      Uint8List image = await MawaqitImageCache.getImage(key.url);

      final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(image);

      return decode(buffer);
    } catch (e, stack) {
      // Log the specific error for debugging
      if (e.toString().contains("No internet connection and image not cached")) {
        logger.w('Image not available offline: ${key.url}');
      } else {
        logger.e('Error loading image: ${key.url}', error: e, stackTrace: stack);
      }

      onError?.call();
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });
      rethrow;
    } finally {
      chunkEvents.close();
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MawaqitNetworkImageProvider && other.url == url && other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() => '${objectRuntimeType(this, 'MawaqitNetworkImageProvider')}("$url", scale: $scale)';
}
