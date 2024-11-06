import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_state.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RtspCameraStreamNotifier extends AsyncNotifier<RtspCameraStreamState> {
  late final Player _player;
  late final VideoController _videoController;
  late final SharedPreferences _prefs;

  VideoController get videoController => _videoController;

  @override
  Future<RtspCameraStreamState> build() async {
    _player = Player();
    _videoController = VideoController(_player);
    _prefs = await SharedPreferences.getInstance();
    return _loadInitialState();
  }

  Future<RtspCameraStreamState> _loadInitialState() async {
    final isEnabled = _prefs.getBool(StreamConstants.prefKeyEnabled) ?? false;
    final url = _prefs.getString(StreamConstants.prefKeyUrl);

    if (!isEnabled || url == null || url.isEmpty) {
      return RtspCameraStreamState.initial();
    }

    final initialState = RtspCameraStreamState(
      isRTSPEnabled: isEnabled,
      streamUrl: url,
      isStreamInitialized: false,
      invalidStreamUrl: false,
      streamType: _getStreamType(url),
      retryCount: 0,
    );

    return _initializeStream(initialState);
  }

  StreamType _getStreamType(String url) {
    final lowercaseUrl = url.toLowerCase();
    if (lowercaseUrl.startsWith('rtsp://')) return StreamType.rtsp;
    if (lowercaseUrl.contains('youtube.com')) return StreamType.youtubeLive;
    return StreamType.unknown;
  }

  String? extractVideoId(String url) {
    try {
      final uri = Uri.parse(url);

      if (uri.host == 'youtu.be') {
        return uri.pathSegments.first;
      }

      if (uri.host.contains('youtube.com')) {
        return uri.queryParameters['v'] ??
            uri.queryParameters['video_id'] ??
            uri.pathSegments.lastWhere((s) => s.isNotEmpty, orElse: () => '');
      }
    } catch (e) {
      debugPrint('Video ID extraction error: $e');
    }
    return null;
  }

  Future<void> updateStream({
    required bool isEnabled,
    String? url,
  }) async {
    state = const AsyncLoading();

    try {
      await _player.stop();
      await _prefs.setBool(StreamConstants.prefKeyEnabled, isEnabled);

      if (url != null) {
        await _prefs.setString(StreamConstants.prefKeyUrl, url);
      }

      if (isEnabled && url != null && url.isNotEmpty) {
        final newState = await _initializeStream(
          RtspCameraStreamState(
            isRTSPEnabled: isEnabled,
            streamUrl: url,
            isStreamInitialized: false,
            invalidStreamUrl: false,
            streamType: _getStreamType(url),
            retryCount: 0,
          ),
        );
        state = AsyncData(newState);
      } else {
        state = AsyncData(RtspCameraStreamState.initial().copyWith(
          isRTSPEnabled: isEnabled,
          streamUrl: url,
          streamType: url != null ? _getStreamType(url) : StreamType.unknown,
        ));
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<RtspCameraStreamState> _initializeStream(RtspCameraStreamState currentState) async {
    YoutubeExplode? yt;

    try {
      switch (currentState.streamType) {
        case StreamType.rtsp:
          await _player.open(Media(currentState.streamUrl!));
          return currentState.copyWith(
            isStreamInitialized: true,
            invalidStreamUrl: false,
          );

        case StreamType.youtubeLive:
          final videoId = extractVideoId(currentState.streamUrl!);
          if (videoId == null) {
            return currentState.copyWith(
              invalidStreamUrl: true,
              isStreamInitialized: false,
            );
          }

          yt = YoutubeExplode();
          final video = await yt.videos.get(videoId);

          if (!video.isLive) {
            return currentState.copyWith(
              invalidStreamUrl: true,
              isStreamInitialized: false,
            );
          }

          return currentState.copyWith(
            isStreamInitialized: true,
            invalidStreamUrl: false,
          );

        case StreamType.unknown:
          return currentState.copyWith(
            invalidStreamUrl: true,
            isStreamInitialized: false,
          );
      }
    } catch (e) {
      debugPrint('Stream initialization error: $e');
      return _isNetworkError(e)
          ? currentState.copyWith(
              invalidStreamUrl: false,
              isStreamInitialized: false,
            )
          : await _handleInitializationError(currentState);
    } finally {
      yt?.close();
    }
  }

  bool _isNetworkError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('network') || errorStr.contains('connection');
  }

  Future<RtspCameraStreamState> _handleInitializationError(
    RtspCameraStreamState currentState,
  ) async {
    if (currentState.retryCount < StreamConstants.maxRetries) {
      await Future.delayed(StreamConstants.retryDelay);
      return _initializeStream(
        currentState.copyWith(
          retryCount: currentState.retryCount + 1,
        ),
      );
    }

    return currentState.copyWith(
      invalidStreamUrl: true,
      isStreamInitialized: false,
    );
  }

  @override
  void dispose() {
    _player.dispose();
  }
}

final rtspCameraStreamProvider = AsyncNotifierProvider<RtspCameraStreamNotifier, RtspCameraStreamState>(
  () => RtspCameraStreamNotifier(),
);
