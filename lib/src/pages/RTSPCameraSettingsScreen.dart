import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_notifier.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_state.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:sizer/sizer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider to track initialization state
final isInitializedProvider = StateProvider<bool>((ref) => false);

class RTSPCameraSettingsScreen extends ConsumerStatefulWidget {
  const RTSPCameraSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RTSPCameraSettingsScreen> createState() => _RTSPCameraSettingsScreenState();
}

class _RTSPCameraSettingsScreenState extends ConsumerState<RTSPCameraSettingsScreen> {
  final TextEditingController _urlController = TextEditingController();
  late StreamSubscription<bool> keyboardSubscription;
  final FocusNode _saveButtonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeSettings();
    var keyboardVisibilityController = KeyboardVisibilityController();

    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        FocusScope.of(context).requestFocus(_saveButtonFocusNode);
      }
    });
  }

  Future<void> _initializeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(RtspCameraStreamConstant.prefKeyEnabled) ?? false;
    final savedUrl = prefs.getString(RtspCameraStreamConstant.prefKeyUrl);

    if (savedUrl != null && savedUrl.isNotEmpty) {
      _urlController.text = savedUrl;
    }

    // Initialize the stream state if enabled
    if (isEnabled) {
      await ref.read(rtspCameraStreamProvider.notifier).updateStream(
            isEnabled: isEnabled,
            url: savedUrl,
          );
    }

    // Mark initialization as complete
    ref.read(isInitializedProvider.notifier).state = true;
  }

  Future<void> _validateAndSaveSettings(RtspCameraStreamState currentState) async {
    if (_urlController.text.isEmpty) return;

    try {
      await ref.read(rtspCameraStreamProvider.notifier).updateStream(
            isEnabled: true,
            url: _urlController.text,
          );

      if (!mounted) return;

      final streamState = ref.read(rtspCameraStreamProvider);
      final isValid = streamState.valueOrNull?.invalidStreamUrl == false;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isValid ? S.of(context).validRtspUrl : S.of(context).invalidRtspUrl,
            style: const TextStyle(fontSize: 16),
          ),
          backgroundColor: isValid ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      log('Stream validation error: $e');
    }
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

  Widget _buildSettingsContent(RtspCameraStreamState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          S.of(context).rtspCameraSettings,
          style: Theme.of(context).textTheme.titleMedium?.apply(fontSizeFactor: 2),
          textAlign: TextAlign.center,
        ),
        const Divider(indent: 50, endIndent: 50),
        const SizedBox(height: 10),
        Text(
          S.of(context).rtspCameraSettingScreenDesc,
          style: Theme.of(context).textTheme.bodySmall?.apply(fontSizeFactor: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        SwitchListTile(
          title: Text(S.of(context).enableRtspCamera),
          value: state.isRTSPEnabled,
          onChanged: (value) async {
            await ref.read(rtspCameraStreamProvider.notifier).updateStream(isEnabled: value, url: _urlController.text);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        if (state.isRTSPEnabled) ...[
          const SizedBox(height: 20),
          Text(
            S.of(context).addRtspUrl,
            style: Theme.of(context).textTheme.bodyLarge?.apply(fontSizeFactor: 1.2),
            textAlign: TextAlign.center,
          ),
          const Divider(indent: 50, endIndent: 50),
          const SizedBox(height: 20),
          TextField(
            controller: _urlController,
            onSubmitted: (_) => _validateAndSaveSettings(state),
            decoration: InputDecoration(
              labelText: S.of(context).enterRtspUrl,
              hintText: 'rtsp://... or https://youtube.com/live/...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            focusNode: _saveButtonFocusNode,
            onPressed: ref.watch(rtspCameraStreamProvider).isLoading ? null : () => _validateAndSaveSettings(state),
            icon: ref.watch(rtspCameraStreamProvider).isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
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
              backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
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
              foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
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

  Widget _buildVideoPreview(RtspCameraStreamState state) {
    if (state.streamType == StreamType.youtubeLive) {
      final videoId = ref.read(rtspCameraStreamProvider.notifier).extractVideoId(state.streamUrl!);
      return YoutubePlayer(
        controller: YoutubePlayerController(
          initialVideoId: videoId ?? '',
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            enableCaption: false,
            hideControls: true,
            isLive: true,
            useHybridComposition: true,
            forceHD: true,
          ),
        ),
      );
    }
    return Video(
      controller: ref.read(rtspCameraStreamProvider.notifier).videoController,
    );
  }

  Widget _buildContent(RtspCameraStreamState? state, bool isLoading) {
    if (state == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: state.isRTSPEnabled && !state.invalidStreamUrl
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                iconSize: 12.sp,
                splashRadius: 7.sp,
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: SafeArea(
        child: Stack(
          children: [
            if (!state.isRTSPEnabled || state.invalidStreamUrl)
              ScreenWithAnimationWidget(
                animation: "settings",
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildSettingsContent(state),
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
                        border: Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: _buildVideoPreview(state),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildSettingsContent(state),
                    ),
                  ),
                ],
              ),
            if (isLoading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInitialized = ref.watch(isInitializedProvider);
    final streamAsync = ref.watch(rtspCameraStreamProvider);

    // Show loading indicator while initializing
    if (!isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _buildContent(
      streamAsync.valueOrNull,
      streamAsync.isLoading,
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
