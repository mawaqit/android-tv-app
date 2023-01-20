import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/models/announcement.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';
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

  /// index can be any number between 1 -> infinity
  final int index;
  final VoidCallback? onDone;

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  late Announcement activeAnnouncement;

  @override
  void initState() {
    final announcements = context.read<MosqueManager>().mosque?.announcements ?? [];

    //todo test this
    if (announcements.isEmpty) Future.delayed(Duration(milliseconds: 0), widget.onDone);

    activeAnnouncement = announcements[widget.index % announcements.length];

    if (activeAnnouncement.video == null) {
      Future.delayed(Duration(seconds: activeAnnouncement.duration ?? 30), widget.onDone);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final announcements = context.read<MosqueManager>().mosque!.announcements;
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
    DateTime? startDate;
    DateTime? endDate;
    if (activeAnnouncement.startDate != null) {
      startDate = DateTime.parse(activeAnnouncement.startDate!);
    }
    if (activeAnnouncement.endDate != null) {
      endDate = DateTime.parse(activeAnnouncement.endDate!);
    }

    // final updatedDate = DateTime.parse(activeAnnouncement.updatedDate!);
    bool isAvailableTime = ((DateTime.now().isBefore(endDate ?? DateTime.now())) &&
        DateTime.now().isAfter(
          startDate ?? DateTime.now(),
        ));
    bool isNoDate = activeAnnouncement.startDate == null || activeAnnouncement.endDate == null;
    print("time$isAvailableTime");
    if (activeAnnouncement.content != null && (isAvailableTime || isNoDate)) {
      return textAnnouncement(activeAnnouncement.content!, activeAnnouncement.title);
    } else if (activeAnnouncement.image != null && (isAvailableTime || isNoDate)) {
      return imageAnnouncement(activeAnnouncement.image!);
    } else if (activeAnnouncement.video != null && (isAvailableTime || isNoDate)) {
      return videoAnnouncement(activeAnnouncement.video!);
    }

    return SizedBox();
  }

  Widget textAnnouncement(String content, String title) {
    return Column(
      children: [
        // title
        AutoSizeText(title,
            stepGranularity: 12,
            textAlign: TextAlign.center,
            style: TextStyle(
                shadows: kAnnouncementTextShadow,
                fontSize: 62,
                fontWeight: FontWeight.bold,
                fontFamily:StringManager.getFontFamily(context),
                color: Colors.amber,
                letterSpacing: 1)),
        // content
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
