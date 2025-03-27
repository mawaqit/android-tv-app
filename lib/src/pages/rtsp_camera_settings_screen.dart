import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/domain/error/rtsp_expceptions.dart';
import 'package:mawaqit/src/services/stream_monitor.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/camera_stream_overlay_notifier.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_notifier.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_state.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:sizer/sizer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class RTSPCameraSettingsScreen extends ConsumerStatefulWidget {
  const RTSPCameraSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RTSPCameraSettingsScreen> createState() =>
      _RTSPCameraSettingsScreenState();
}

class _RTSPCameraSettingsScreenState
    extends ConsumerState<RTSPCameraSettingsScreen> {
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _saveButtonFocusNode = FocusNode();
  late StreamSubscription<bool> keyboardSubscription;
  StreamMonitorService? _streamMonitorService;

  @override
  void initState() {
    super.initState();
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        FocusScope.of(context).requestFocus(_saveButtonFocusNode);
      }
    });
    
    // Initialize stream monitoring
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStreamMonitoring();
    });
  }

  void _initializeStreamMonitoring() {
    // Get the stream overlay settings notifier
    final overlaySettingsNotifier =
        ref.read(streamOverlaySettingsProvider.notifier);

    // Create a stream monitor service with callback to the settings notifier
    _streamMonitorService = StreamMonitorService(
        onStreamStatusChanged:
            overlaySettingsNotifier.handleStreamStatusChange);

    // Start monitoring if we have a valid URL and RTSP is enabled
    final rtspState = ref.read(rtspCameraSettingsProvider);
    if (rtspState.hasValue &&
        rtspState.value!.isRTSPEnabled &&
        rtspState.value!.streamUrl != null) {
      _streamMonitorService?.startMonitoring(rtspState.value!.streamUrl!,
          rtspState.value!.streamType ?? StreamType.youtubeLive);

      // Immediately check the stream status when initializing
      _streamMonitorService?.checkAndNotify();
    }
}

  @override
  void dispose() {
    _urlController.dispose();
    keyboardSubscription.cancel();
    _streamMonitorService?.dispose();
    super.dispose();
  }

  void _updateUrlController(RTSPCameraSettingsState state) {
    if (state.streamUrl != null && _urlController.text != state.streamUrl) {
      _urlController.text = state.streamUrl!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(rtspCameraSettingsProvider);
    // Watch stream overlay settings to reflect their current state
    final overlaySettings = ref.watch(streamOverlaySettingsProvider);
    
    ref.listen(rtspCameraSettingsProvider, (previous, next) {
      if (next.hasValue) {
        _updateUrlController(next.value!);
        
        // If RTSP settings change, update stream monitoring
        if (previous?.value?.streamUrl != next.value?.streamUrl ||
            previous?.value?.streamType != next.value?.streamType ||
            previous?.value?.isRTSPEnabled != next.value?.isRTSPEnabled) {
          if (next.value!.isRTSPEnabled && next.value!.streamUrl != null) {
            // Start or update monitoring
            _streamMonitorService?.startMonitoring(next.value!.streamUrl!,
                next.value!.streamType ?? StreamType.youtubeLive);
          } else {
            // Stop monitoring if disabled
            _streamMonitorService?.stopMonitoring();
          }
        }
      }
      
      if (previous != next &&
          !next.isLoading &&
          next.hasValue &&
          !next.hasError &&
          next.value!.isRTSPEnabled) {
        final state = next.value!;

        // Only show snackbar when URL validation status changes
        ScaffoldMessenger.of(context).clearSnackBars();

        String message;
        Color backgroundColor;

        if (state.streamUrl != null && !state.isInvalidUrl) {
          message = S.of(context).validRtspUrl;
          backgroundColor = Colors.green;
        } else if (state.isInvalidUrl) {
          message = S.of(context).invalidRtspUrl;
          backgroundColor = Colors.red;
        } else {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    });

    return asyncState.when(
      data: (state) {
        return Scaffold(
          appBar: state.isRTSPEnabled
              ? AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    iconSize: 12.sp,
                    splashRadius: 7.sp,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                )
              : null,
          body: SafeArea(
            child: Stack(
              children: [
                if (!state.isRTSPEnabled)
                  ScreenWithAnimationWidget(
                    animation: "settings",
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildSettingsContent(state, overlaySettings),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).dividerColor),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: _buildVideoPreview(state),
                              ),
                              // Show LIVE indicator if stream is live
                              if (overlaySettings.isStreamActuallyLive)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'LIVE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                              // Show overlay if it should be visible based on settings
                              if (overlaySettings.shouldShowOverlay)
                                Positioned.fill(
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'STREAM OVERLAY ACTIVE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildSettingsContent(state, overlaySettings),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        body: _buildLoadingOverlay(),
      ),
      error: (error, stackTrace) {
        if (error is RTSPCameraException) {
          return _buildErrorScreen(error);
        } else {
          return _buildErrorScreen(RTSPStreamUpdateException(error.toString()));
        }
      },
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  S.of(context).validatingStream,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(RTSPCameraException error) {
    String errorMessage = '';

    errorMessage = S.of(context).somethingWentWrong;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(rtspCameraSettingsProvider);
              },
              child: Text(S.of(context).tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview(RTSPCameraSettingsState state) {
    if (state.streamType == StreamType.youtubeLive &&
        state.youtubeController != null) {
      return YoutubePlayer(controller: state.youtubeController!);
    }
    if (state.videoController != null) {
      return Video(controller: state.videoController!);
    }
    return const SizedBox.shrink();
  }

  Widget _buildSettingsContent(
      RTSPCameraSettingsState state, StreamOverlaySettings overlaySettings) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          S.of(context).rtspCameraSettings,
          style:
              Theme.of(context).textTheme.titleMedium?.apply(fontSizeFactor: 2),
          textAlign: TextAlign.center,
        ),
        const Divider(indent: 50, endIndent: 50),
        const SizedBox(height: 10),
        Text(
          S.of(context).rtspCameraSettingScreenDesc,
          style:
              Theme.of(context).textTheme.bodySmall?.apply(fontSizeFactor: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        SwitchListTile(
          title: Text(S.of(context).enableRtspCamera),
          value: state.isRTSPEnabled,
          onChanged: (value) {
            ref.read(rtspCameraSettingsProvider.notifier).toggleEnabled(value);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        if (state.isRTSPEnabled) ...[
          const SizedBox(height: 20),
SwitchListTile(
            title: Text("Auto show overlay when stream is live"),
            subtitle: Text(overlaySettings.isStreamActuallyLive
                ? "Stream is currently live"
                : "Stream is currently offline"),
            value: overlaySettings.autoOverlayEnabled,
            onChanged: (value) {
              ref
                  .read(streamOverlaySettingsProvider.notifier)
                  .toggleAutoOverlay(value);

              // If enabling auto overlay, immediately check stream status
              if (value && _streamMonitorService != null) {
                // Schedule a micro-task to ensure state is updated first
                Future.microtask(() => _streamMonitorService!.checkAndNotify());
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          // Display current status
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: overlaySettings.shouldShowOverlay
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: overlaySettings.shouldShowOverlay
                    ? Colors.green
                    : Colors.grey,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  overlaySettings.shouldShowOverlay
                      ? Icons.check_circle
                      : Icons.info,
                  color: overlaySettings.shouldShowOverlay
                      ? Colors.green
                      : Colors.grey,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    overlaySettings.shouldShowOverlay
                        ? "Overlay is active because stream is live"
                        : overlaySettings.autoOverlayEnabled
                            ? "Overlay will show automatically when stream becomes live"
                            : "Overlay is disabled",
                    style: TextStyle(
                      color: overlaySettings.shouldShowOverlay
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            S.of(context).addRtspUrl,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.apply(fontSizeFactor: 1.2),
            textAlign: TextAlign.center,
          ),
          const Divider(indent: 50, endIndent: 50),
          const SizedBox(height: 20),
          TextField(
            controller: _urlController,
            onSubmitted: (_) =>
                ref.read(rtspCameraSettingsProvider.notifier).updateStream(
                      isEnabled: true,
                      url: _urlController.text,
                    ),
            decoration: InputDecoration(
              labelText: S.of(context).enterRtspUrl,
              hintText: S.of(context).hintTextRtspUrl,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            focusNode: _saveButtonFocusNode,
            onPressed: () =>
                ref.read(rtspCameraSettingsProvider.notifier).updateStream(
                      isEnabled: true,
                      url: _urlController.text,
                    ),
            icon: const Icon(Icons.save),
            label: Text(S.of(context).save),
            style: ButtonStyle(
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              backgroundColor:
                  MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.focused)) {
                  return Theme.of(context).primaryColor;
                }
                return Colors.white;
              }),
              iconColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.focused)) {
                  return Colors.white;
                }
                return Colors.black;
              }),
              foregroundColor:
                  MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.focused)) {
                  return Colors.white;
                }
                return Colors.black;
              }),
            ),
          )
        ],
      ],
    );
  }
}
