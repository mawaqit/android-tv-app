import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/models/address_model.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_notifier.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_state.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    super.initState();
    invalidStreamUrl = context.read<MosqueManager>().mosque?.streamUrl == null;
  }

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.read<MosqueManager>();
    final userPrefs = context.watch<UserPreferencesManager>();
    final connectivity = ref.watch(connectivityProvider);
    final streamState = ref.watch(rtspCameraStreamProvider);

    final jumuaaDisableInMosque = !userPrefs.isSecondaryScreen && mosqueManager.typeIsMosque;

    return switch (connectivity) {
      AsyncData(:final value) => streamState.when(
          data: (state) => switchStreamWidget(value, mosqueManager, jumuaaDisableInMosque, state),
          loading: () => CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          error: (_, __) => switchStreamWidget(value, mosqueManager, jumuaaDisableInMosque, null),
        ),
      _ => CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
    };
  }

  Widget switchStreamWidget(ConnectivityStatus connectivityStatus, MosqueManager mosqueManager,
      bool jumuaaDisableInMosque, RtspCameraStreamState? streamState) {
    // Check for RTSP stream first
    if (streamState != null &&
        streamState.isRTSPEnabled &&
        streamState.isRTSPInitialized &&
        !streamState.invalidRTSPUrl &&
        connectivityStatus != ConnectivityStatus.disconnected) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Video(
              controller: ref.read(rtspCameraStreamProvider.notifier).videoController,
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
      return Scaffold(backgroundColor: Colors.black);
    } else {
      return MawaqitYoutubePlayer(
        channelId: mosqueManager.mosque!.streamUrl!,
        onDone: widget.onDone,
        muted: mosqueManager.typeIsMosque,
        onNotFound: () => setState(() => invalidStreamUrl = true),
      );
    }
  }
}
