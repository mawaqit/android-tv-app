import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/main.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MawaqitYoutubePlayer extends StatefulWidget {
  const MawaqitYoutubePlayer({
    super.key,
    this.onDone,
    this.onNotFound,
    this.videoId,
    this.channelId,
    this.url,
    this.muted = false,
  }) : assert(videoId != null || channelId != null || url != null, 'videoId, channelId or url must not be null');

  final VoidCallback? onDone;

  ///
  final VoidCallback? onNotFound;

  /// get stream video id from channel id using youtube_explode_dart
  final String? channelId;
  final String? videoId;
  final String? url;

  final bool muted;

  /// get channel stream video id from channel id using youtube_explode_dart
  static Future<String?> getStreamVideoId(String channelID) async {
    final yt = YoutubeExplode();

    final videos = yt.channels.getUploads(channelID);

    await for (final video in videos.take(10)) {
      if (video.duration == null) {
        return video.id.value;
      }
    }

    return null;
  }

  @override
  State<MawaqitYoutubePlayer> createState() => _YoutubePlayerState();
}

class _YoutubePlayerState extends State<MawaqitYoutubePlayer> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    if (widget.videoId != null) {
      setupController(widget.videoId!);
    } else if (widget.channelId != null) {
      MawaqitYoutubePlayer.getStreamVideoId(widget.channelId!).then((value) => setState(() => setupController(value)));
    } else if (widget.url != null) {
      final id = YoutubePlayer.convertUrlToId(widget.url!);

      setupController(id);
    }
    super.initState();
  }

  setupController(String? id) {
    logger.d('Playing video with id: $id');
    if (id == null) {
      widget.onNotFound?.call();
    } else {
      _controller = YoutubePlayerController(
        initialVideoId: id,
        flags: YoutubePlayerFlags(
          autoPlay: true,
          mute: widget.muted,
          enableCaption: false,
          hideControls: true,
          useHybridComposition: false,
          forceHD: true,
        ),
      );

      Future.delayed(20.seconds, () {
        if (_controller!.value.isReady == false) widget.onNotFound?.call();
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) return SizedBox();

    final size = MediaQuery.of(context).size;

    return YoutubePlayer(
      aspectRatio: size.width / size.height,
      controller: _controller!,
      onEnded: (metaData) => widget.onDone?.call(),
    );
    // return InAppWebView();
  }
}
