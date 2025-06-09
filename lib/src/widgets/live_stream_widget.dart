import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state_management/livestream_viewer/live_stream_notifier_v2.dart';
import '../state_management/livestream_viewer/live_stream_state_v2.dart';

/// Simplified live stream widget that uses the refactored components
class LiveStreamWidget extends ConsumerWidget {
  final bool showControls;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const LiveStreamWidget({
    Key? key,
    this.showControls = false,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamState = ref.watch(liveStreamProviderV2);

    return streamState.when(
      data: (state) => _buildStreamContent(context, ref, state),
      loading: () => _buildLoadingWidget(),
      error: (error, stack) => _buildErrorWidget(error.toString()),
    );
  }

  Widget _buildStreamContent(BuildContext context, WidgetRef ref, LiveStreamState state) {
    // Show error state
    if (state.hasError) {
      return _buildErrorWidget(state.errorMessage ?? 'Stream error occurred');
    }

    // Show connecting state
    if (state.isConnecting) {
      return _buildConnectingWidget();
    }

    // Show stream widget if ready
    if (state.isReadyToPlay && state.streamWidget != null) {
      return _buildStreamDisplay(context, ref, state);
    }

    // Show placeholder for disabled or no stream
    return _buildPlaceholderWidget(state);
  }

  Widget _buildStreamDisplay(BuildContext context, WidgetRef ref, LiveStreamState state) {
    Widget streamContent = Container(
      padding: padding,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: state.streamWidget!,
        ),
      ),
    );

    if (showControls) {
      return Stack(
        children: [
          streamContent,
          _buildControlsOverlay(context, ref, state),
        ],
      );
    }

    return streamContent;
  }

  Widget _buildControlsOverlay(BuildContext context, WidgetRef ref, LiveStreamState state) {
    return Positioned(
      top: 16,
      right: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pause/Resume button
          IconButton(
            onPressed: () {
              // Note: In the refactored version, we could add play/pause state
              // ref.read(liveStreamProviderV2.notifier).pauseStream();
            },
            icon: const Icon(Icons.pause, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 8),
          // Close button (for workflow replacement)
          if (state.replaceWorkflow)
            IconButton(
              onPressed: () {
                ref.read(liveStreamProviderV2.notifier).toggleReplaceWorkflow(false);
              },
              icon: const Icon(Icons.close, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }

  Widget _buildConnectingWidget() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'Connecting to stream...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Stream Error',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderWidget(LiveStreamState state) {
    if (!state.isEnabled) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            'Live stream is disabled',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: const Center(
        child: Text(
          'No stream configured',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
} 