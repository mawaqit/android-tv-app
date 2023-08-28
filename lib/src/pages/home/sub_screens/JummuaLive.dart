import 'package:flutter/material.dart';
import 'package:mawaqit/src/pages/home/sub_screens/JumuaHadithSubScreen.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/src/widgets/mawaqit_youtube_palyer.dart';
import 'package:provider/provider.dart';

import '../../../services/mosque_manager.dart';

class JummuaLive extends StatefulWidget {
  const JummuaLive({
    Key? key,
    this.onDone,
  }) : super(key: key);

  final VoidCallback? onDone;

  @override
  State<JummuaLive> createState() => _JummuaLiveState();
}

class _JummuaLiveState extends State<JummuaLive> {
  /// invalid channel id
  bool invalidStreamUrl = false;

  @override
  void initState() {
    invalidStreamUrl = context.read<MosqueManager>().mosque?.streamUrl == null;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.read<MosqueManager>();
    final userPrefs = context.watch<UserPreferencesManager>();

    /// disable live stream in mosque primary screen
    final jumuaaDisableInMosque = !userPrefs.isSecondaryScreen && mosqueManager.typeIsMosque;

    if (invalidStreamUrl || mosqueManager.mosque?.streamUrl == null || jumuaaDisableInMosque) {
      if (mosqueManager.mosqueConfig!.jumuaDhikrReminderEnabled == true) return JumuaHadithSubScreen(onDone: widget.onDone);

      return Scaffold(backgroundColor: Colors.black);
    }

    return MawaqitYoutubePlayer(
      channelId: mosqueManager.mosque!.streamUrl!,
      onDone: widget.onDone,
      muted: mosqueManager.typeIsMosque,
      onNotFound: () => setState(() => invalidStreamUrl = true),
    );
  }
}
