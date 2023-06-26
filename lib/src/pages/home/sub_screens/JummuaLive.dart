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
    this.duration = 30,
  }) : super(key: key);

  final VoidCallback? onDone;
  final int duration;

  @override
  State<JummuaLive> createState() => _JummuaLiveState();
}

class _JummuaLiveState extends State<JummuaLive> {
  bool showHadith = false;

  @override
  void initState() {
    showHadith = context.read<MosqueManager>().mosque?.streamUrl == null;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.read<MosqueManager>();
    final userPrefs = context.watch<UserPreferencesManager>();

    if (showHadith) return JumuaHadithSubScreen(onDone: widget.onDone);

    if (!userPrefs.isSecondaryScreen && mosqueManager.typeIsMosque) {
      return Scaffold(backgroundColor: Colors.black);
    }

    return MawaqitYoutubePlayer(
      channelId: mosqueManager.mosque!.streamUrl!,
      onDone: widget.onDone,
      muted: mosqueManager.typeIsMosque,
      onNotFound: () => setState(() => showHadith = true),
    );
  }
}
