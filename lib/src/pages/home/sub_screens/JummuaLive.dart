import 'package:flutter/material.dart';
import 'package:mawaqit/src/services/developer_manager.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../helpers/HiveLocalDatabase.dart';
import '../../../services/mosque_manager.dart';

class JummuaLive extends StatefulWidget {
  const JummuaLive({Key? key}) : super(key: key);

  @override
  State<JummuaLive> createState() => _JummuaLiveState();
}

class _JummuaLiveState extends State<JummuaLive> {
  @override
  Widget build(BuildContext context) {
    // final mosqueProvider = context.watch<MosqueManager>();
    //
    // if (mosqueProvider.mosque == null || mosqueProvider.times == null) return SizedBox();
    //
    // final mosque = mosqueProvider.mosque!;
    final hive = context.watch<HiveManager>();
    if (!hive.isSecondaryScreen()) {
      return Scaffold(
        backgroundColor: Colors.black,
      );
    }
    return liveStream("https://www.youtube.com/watch?v=NP-hZRXIrYs");
  }

  Widget liveStream(String video) {
    late YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(
        video,
      )!,
      flags: YoutubePlayerFlags(
        showLiveFullscreenButton: false,
        isLive: true,
        hideControls: true,
        autoPlay: true,

        /// todo if type is mosque live is mute
        //mute: isMosque?false:true
      ),
    );
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
    );
  }
}
