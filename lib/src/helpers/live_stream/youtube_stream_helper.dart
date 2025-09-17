import 'dart:async';
import 'dart:developer' as dev;

import 'package:mawaqit/src/domain/error/live_stream_exceptions.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Helper class to handle YouTube stream operations
class YouTubeStreamHelper {
  YoutubePlayerController? _controller;

  /// Get the current active controller
  YoutubePlayerController? get controller => _controller;

  /// Clean up resources
  Future<void> dispose() async {
    if (_controller != null) {
      try {
        final controllerToDispose = _controller!;
        _controller = null;
        controllerToDispose.dispose();
        dev.log('🎥 [YOUTUBE_HELPER] Disposed YouTube controller');
      } catch (e) {
        dev.log('⚠️ [YOUTUBE_HELPER] Error disposing YouTube controller: $e');
        _controller = null;
      }
    }
  }

  /// Extract YouTube video ID from URL
  String? extractVideoId(String url) {
    dev.log('🔍 [YOUTUBE_HELPER] Extracting video ID from URL: $url');

    // Handle live URLs in the format youtube.com/live/VIDEO_ID
    if (url.contains('youtube.com/live/')) {
      try {
        final id = url.split('youtube.com/live/')[1].split('?').first;
        dev.log('✅ [YOUTUBE_HELPER] Extracted ID from live URL: $id');
        return id;
      } catch (e) {
        dev.log('⚠️ [YOUTUBE_HELPER] Error extracting ID from live URL: $e');
        // Fall through to standard extraction
      }
    }

    // Standard youtube URL extraction
    final regularId = YoutubePlayer.convertUrlToId(url);
    dev.log('🔍 [YOUTUBE_HELPER] Standard YouTube ID extraction result: $regularId');

    // If the URL format is different, try manual extraction
    if (regularId == null) {
      final uri = Uri.tryParse(url);
      if (uri != null && (uri.host == 'youtube.com' || uri.host == 'www.youtube.com')) {
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          if (pathSegments.contains('live')) {
            final liveIndex = pathSegments.indexOf('live');
            if (liveIndex < pathSegments.length - 1) {
              final potentialId = pathSegments[liveIndex + 1];
              dev.log('🔍 [YOUTUBE_HELPER] Manual extraction from pathSegments: $potentialId');
              return potentialId;
            }
          }
          // Try to find the ID in other path segments
          for (final segment in pathSegments) {
            if (segment.length > 8) {
              // Most YouTube IDs are longer than 8 chars
              dev.log('🔍 [YOUTUBE_HELPER] Trying path segment as ID: $segment');
              return segment;
            }
          }
        }
      }
    }

    return regularId;
  }

  /// Validate if a YouTube video is a live stream
  Future<bool> validateLiveStream(String videoId) async {
    try {
      dev.log('🔍 [YOUTUBE_HELPER] Validating YouTube video with YoutubeExplode');
      final yt = YoutubeExplode();

      try {
        // First check if the video exists and we can get its metadata
        final video = await yt.videos.get(videoId).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            dev.log('⏰ [YOUTUBE_HELPER] Timeout validating YouTube video');
            throw TimeoutException('Timed out attempting to validate YouTube video');
          },
        );

        // Check if the video is marked as a live stream
        final isLive = video.isLive;
        dev.log('🎥 [YOUTUBE_HELPER] YouTube video is live: $isLive');

        // Close the YoutubeExplode client
        yt.close();

        return isLive;
      } catch (e) {
        // Make sure to close the client even if an error occurs
        yt.close();
        rethrow;
      }
    } catch (e) {
      dev.log('⚠️ [YOUTUBE_HELPER] Error checking if YouTube video is live: $e');
      throw LiveStreamInitializationException('Unable to verify if YouTube video is a live stream: $e');
    }
  }

  /// Initialize a YouTube player controller for the given video ID
  YoutubePlayerController initializeController(String videoId) {
    // Dispose existing controller if any
    dispose();

    // Create a new controller
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        hideControls: true,
        isLive: true,
        useHybridComposition: false,
        forceHD: false,
      ),
    );

    dev.log('🎥 [YOUTUBE_HELPER] Created YouTube player controller');
    return _controller!;
  }

  /// Process a YouTube URL and return a valid video ID
  /// Throws an exception if the URL is invalid or not a live stream
  Future<String> processYouTubeUrl(String url) async {
    dev.log('🔍 [YOUTUBE_HELPER] Processing YouTube URL: $url');

    // Extract video ID
    final videoId = extractVideoId(url);
    if (videoId == null || videoId.isEmpty) {
      dev.log('❌ [YOUTUBE_HELPER] Could not extract video ID from URL: $url');
      throw InvalidStreamUrlException('Could not extract valid video ID from YouTube URL');
    }

    // Validate live stream
    final isLive = await validateLiveStream(videoId);
    if (!isLive) {
      dev.log('❌ [YOUTUBE_HELPER] YouTube video is not a live stream: $videoId');
      throw InvalidStreamUrlException('This YouTube URL is not a live stream. Only live streams can be used.');
    }

    // Return standardized URL format
    return videoId;
  }
}
