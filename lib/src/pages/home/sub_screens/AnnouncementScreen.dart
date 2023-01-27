import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/models/announcement.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';
import 'package:mawaqit/src/services/mixins/mosque_helpers_mixins.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../helpers/StringUtils.dart';
import '../widgets/SalahTimesBar.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({
    Key? key,
    required this.index,
    this.onDone,
  }) : super(key: key);

  /// index can be any number between 0 -> infinity
  final int index;
  final VoidCallback? onDone;

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  late Announcement activeAnnouncement;

  @override
  void initState() {
    final announcements = context.read<MosqueManager>().activeAnnouncements;

    //todo test this
    if (announcements.isEmpty) Future.delayed(Duration(milliseconds: 0), widget.onDone);

    activeAnnouncement = announcements[widget.index % announcements.length];

    if (activeAnnouncement.video == null) {
      Future.delayed(
        Duration(seconds: activeAnnouncement.duration ?? 30) * kTestDurationFactor,
        widget.onDone,
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final announcements = context.read<MosqueManager>().activeAnnouncements;

    if (announcements.isEmpty) return NormalHomeSubScreen();

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        announcementWidgets(),
        IgnorePointer(
          child: Padding(
            padding: EdgeInsets.only(bottom: 1.5.vh),
            child: SalahTimesBar(
              miniStyle: true,
              microStyle: true,
            ),
          ),
        )
      ],
    );
  }

  Widget announcementWidgets() {
    if (activeAnnouncement.content != null) {
      return textAnnouncement(activeAnnouncement.content!, activeAnnouncement.title);
    } else if (activeAnnouncement.image != null) {
      return imageAnnouncement(activeAnnouncement.image!);
    } else if (activeAnnouncement.video != null) {
      return videoAnnouncement(activeAnnouncement.video!);
    }

    return SizedBox();
  }

  Widget textAnnouncement(String content, String title) {
    return Column(
      children: [
        // title
        SizedBox(
          height: 2.vh,
        ),
        AutoSizeText(title,
            stepGranularity: 12,
            textAlign: TextAlign.center,
            style: TextStyle(
                shadows: kAnnouncementTextShadow,
                fontSize: 62,
                fontWeight: FontWeight.bold,
                fontFamily: StringManager.getFontFamily(context),
                color: Colors.amber,
                letterSpacing: 1)),
        // content
        SizedBox(
          height: 3.vh,
        ),
        Expanded(
          child: AutoSizeText(content,
              stepGranularity: 12,
              textAlign: TextAlign.center,
              style: TextStyle(
                  shadows: kAnnouncementTextShadow,
                  fontSize: 62,
                  fontWeight: FontWeight.bold,
                  fontFamily: StringManager.getFontFamily(context),
                  color: Colors.white,
                  letterSpacing: 1)),
        ),
      ],
    );
  }

  Widget imageAnnouncement(String image) {
    return Image.network(
      image,
      fit: BoxFit.cover,
    );
  }

  Widget videoAnnouncement(String video) {
    late YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(
        video,
      )!,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: true,
      ),
    );
    return Stack(
      children: [
        YoutubePlayer(
          onEnded: (metaData) => widget.onDone?.call(),
          controller: _controller,
          showVideoProgressIndicator: true,
        ),
      ],
    );
  }

  get kAnnouncementTextShadow => [
        Shadow(
          offset: Offset(0, 9),
          blurRadius: 15,
          color: Colors.black54,
        ),
      ];
}
