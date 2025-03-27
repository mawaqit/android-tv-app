import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_notifier.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class StreamMonitorService {
  Timer? _monitorTimer;
  final void Function(bool isLive) onStreamStatusChanged;
  final _youtubeExplode = YoutubeExplode();
  bool _isMonitoring = false;
  bool _lastKnownStatus = false;
  String? _currentUrl;
  StreamType? _currentStreamType;

  StreamMonitorService({required this.onStreamStatusChanged});

  Future<bool> checkStreamStatus(String url, StreamType streamType) async {
    try {
      if (streamType == StreamType.youtubeLive) {
        String? videoId;

        if (url.contains('youtube.com/live/')) {
          videoId = url.split('youtube.com/live/')[1].split('?').first;
        } else {
          videoId = YoutubePlayer.convertUrlToId(url);
        }

        if (videoId != null) {
          try {
            final video = await _youtubeExplode.videos.get(videoId);
            debugPrint("YouTube Live status for $videoId: ${video.isLive}");
            return video.isLive;
          } catch (e) {
            debugPrint("Error checking YouTube live status: $e");
            return false;
          }
        }
      } else if (streamType == StreamType.rtsp) {
        final player = Player();
        try {
          await player.open(Media(url));
          await Future.delayed(
              const Duration(seconds: 3)); // Allow stream to buffer

          // Check if we have valid video dimensions
          final dimensions =
              player.state.width != null && player.state.height != null;
          final isPlaying = player.state.playing && dimensions;

          debugPrint(
              "RTSP status for $url: $isPlaying (Dimensions: ${player.state.width}x${player.state.height})");

          await player.dispose();
          return isPlaying;
        } catch (e) {
          debugPrint("Error checking RTSP status: $e");
          await player.dispose();
          return false;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error checking stream status: $e');
      return false;
    }
  }

  void startMonitoring(String url, StreamType streamType) {
    // Don't restart if already monitoring the same URL
    if (_isMonitoring &&
        _currentUrl == url &&
        _currentStreamType == streamType) {
      debugPrint("Already monitoring this stream: $url");
      return;
    }

    stopMonitoring(); // Stop existing timer if any

    _isMonitoring = true;
    _currentUrl = url;
    _currentStreamType = streamType;
    debugPrint("Started monitoring stream: $url (Type: $streamType)");

    // Initial check with notification
    checkAndNotify();

    // Periodic monitoring - adjust timing as needed
    // (30 seconds might be more appropriate for production)
    _monitorTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_isMonitoring) {
        checkAndNotify();
      }
    });
  }

  Future<void> checkAndNotify() async {
    if (_currentUrl != null && _currentStreamType != null) {
      final isLive = await checkStreamStatus(_currentUrl!, _currentStreamType!);

      // Only notify if status changed to avoid repeated callbacks
      if (isLive != _lastKnownStatus) {
        debugPrint("Stream status changed: $isLive");
        _lastKnownStatus = isLive;
        onStreamStatusChanged(isLive);
      }
    }
  }

  void stopMonitoring() {
    if (!_isMonitoring) return;

    _isMonitoring = false;
    _monitorTimer?.cancel();
    _monitorTimer = null;
    _currentUrl = null;
    _currentStreamType = null;
    debugPrint("Stopped monitoring stream");
  }

  void dispose() {
    stopMonitoring();
    _youtubeExplode.close();
    debugPrint("StreamMonitorService disposed");
  }
}
