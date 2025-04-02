import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// A safer wrapper for YouTube Player that handles disposed controllers gracefully
class SafeYoutubePlayer extends StatefulWidget {
  /// The YouTube player controller to use
  final YoutubePlayerController controller;

  /// Optional placeholder to show when controller is unavailable
  final Widget? placeholder;

  /// Optional callback when an error occurs
  final Function(dynamic error)? onError;

  /// Optional callback when video ends
  final VoidCallback? onEnded;

  /// Optional callback when video is ready
  final VoidCallback? onReady;

  const SafeYoutubePlayer({
    Key? key,
    required this.controller,
    this.placeholder,
    this.onError,
    this.onEnded,
    this.onReady,
  }) : super(key: key);

  @override
  State<SafeYoutubePlayer> createState() => _SafeYoutubePlayerState();
}

class _SafeYoutubePlayerState extends State<SafeYoutubePlayer> {
  bool _isControllerValid = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _checkControllerValidity();
  }

  @override
  void didUpdateWidget(SafeYoutubePlayer oldWidget) {
    // Only update if the component hasn't been disposed
    // and the controller has actually changed
    if (!_isDisposed && oldWidget.controller != widget.controller) {
      _checkControllerValidity();
    }
    // If controller is the same reference but might be disposed, recheck validity
    else if (!_isDisposed && _isControllerValid) {
      _checkControllerValidity();
    }
    // Skip parent didUpdateWidget if we detected disposal or invalid controller
    else if (!_isDisposed) {
      super.didUpdateWidget(oldWidget);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _checkControllerValidity() {
    try {
      // This will throw if the controller is disposed
      // We explicitly check addListener which will throw early
      // if the controller is disposed
      bool isDisposed = false;
      try {
        widget.controller.addListener(() {});
        widget.controller.removeListener(() {});
      } catch (e) {
        isDisposed = true;
        log('Controller detected as disposed: $e');
      }

      // Don't check isReady here as it might be false for new controllers
      // just check if the controller is not disposed
      _isControllerValid = !isDisposed;

      if (!_isControllerValid && widget.onError != null && !_isDisposed) {
        widget.onError!('Controller is disposed or not ready');
      }
    } catch (e) {
      _isControllerValid = false;
      if (widget.onError != null && !_isDisposed) {
        widget.onError!(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return const SizedBox.shrink();
    }

    if (!_isControllerValid) {
      return widget.placeholder ??
          Center(
            child: Text(
              'Video not available',
              style: TextStyle(color: Colors.grey),
            ),
          );
    }

    // Only create the YoutubePlayer if controller is valid
    try {
      return YoutubePlayer(
        controller: widget.controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Theme.of(context).primaryColor,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
        onReady: () {
          if (_isDisposed) return;

          log('YouTube player is ready');
          // Make sure the video is playing
          try {
            widget.controller.play();
          } catch (e) {
            log('Error playing video in onReady: $e');
          }
          if (widget.onReady != null) {
            widget.onReady!();
          }
        },
        onEnded: (data) {
          if (_isDisposed) return;

          log('YouTube video ended: ${data.videoId}');
          if (widget.onEnded != null) {
            widget.onEnded!();
          }
        },
      );
    } catch (e) {
      // If we get here, controller was valid during check but became invalid
      log('Error building YouTube player: $e');
      if (widget.onError != null && !_isDisposed) {
        widget.onError!(e);
      }

      return widget.placeholder ??
          Center(
            child: Text(
              'Video playback error',
              style: TextStyle(color: Colors.grey),
            ),
          );
    }
  }
}
