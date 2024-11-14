import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/models/address_model.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_notifier.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_state.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../main.dart';
import '../../../helpers/connectivity_provider.dart';
import '../../../services/user_preferences_manager.dart';
import '../../../widgets/mawaqit_youtube_palyer.dart';
import 'JumuaHadithSubScreen.dart';

class JummuaLive extends ConsumerStatefulWidget {
  const JummuaLive({
    Key? key,
    this.onDone,
  }) : super(key: key);

  final VoidCallback? onDone;

  @override
  ConsumerState createState() => _JummuaLiveState();
}

class _JummuaLiveState extends ConsumerState<JummuaLive> {
  bool invalidStreamUrl = false;

  @override
  void initState() {
    invalidStreamUrl = context.read<MosqueManager>().mosque?.streamUrl == null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quranNotifierProvider.notifier).exitQuranMode();
    });

    log('JummuaLive: invalidStreamUrl: $invalidStreamUrl');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.read<MosqueManager>();
    final userPrefs = context.watch<UserPreferencesManager>();
    final connectivity = ref.watch(connectivityProvider);
    final streamStateAsync = ref.watch(rtspCameraSettingsProvider);

    final jumuaaDisableInMosque = !userPrefs.isSecondaryScreen && mosqueManager.typeIsMosque;

    return connectivity.when(
      data: (value) => streamStateAsync.when(
        data: (streamState) => _switchStreamWidget(
          value,
          mosqueManager,
          jumuaaDisableInMosque,
          streamState,
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        error: (error, stack) => _switchStreamWidget(
          value,
          mosqueManager,
          jumuaaDisableInMosque,
          RTSPCameraSettingsState(isLoading: false),
        ),
      ),
      loading: () => const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
      error: (_, __) => _switchStreamWidget(
        ConnectivityStatus.disconnected,
        mosqueManager,
        jumuaaDisableInMosque,
        RTSPCameraSettingsState(isLoading: false),
      ),
    );
  }

  Widget _switchStreamWidget(
    ConnectivityStatus connectivityStatus,
    MosqueManager mosqueManager,
    bool jumuaaDisableInMosque,
    RTSPCameraSettingsState streamState,
  ) {
    // Check for RTSP stream first
    if (streamState.isRTSPEnabled &&
        !streamState.invalidStreamUrl &&
        streamState.streamType == StreamType.rtsp &&
        streamState.videoController != null &&
        connectivityStatus != ConnectivityStatus.disconnected) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Video(
              controller: streamState.videoController!,
            ),
          ),
        ),
      );
    }

    // Fall back to YouTube or Hadith screen
    if (invalidStreamUrl ||
        mosqueManager.mosque?.streamUrl == null ||
        jumuaaDisableInMosque ||
        connectivityStatus == ConnectivityStatus.disconnected) {
      if (mosqueManager.mosqueConfig!.jumuaDhikrReminderEnabled == true) {
        return JumuaHadithSubScreen(onDone: widget.onDone);
      }
      return const Scaffold(backgroundColor: Colors.black);
    } else {
      return streamState.invalidStreamUrl || streamState.streamUrl == null
          ? MawaqitYoutubePlayer(
              channelId: mosqueManager.mosque!.streamUrl!,
              onDone: widget.onDone,
              muted: mosqueManager.typeIsMosque,
              onNotFound: () => setState(() => invalidStreamUrl = true),
            )
          : streamState.youtubeController != null
              ? YoutubePlayer(
                  controller: streamState.youtubeController!,
                )
              : const Scaffold(backgroundColor: Colors.black);
    }
  }
}
