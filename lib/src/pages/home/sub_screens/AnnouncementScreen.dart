import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/models/announcement.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../helpers/StringUtils.dart';
import '../widgets/SalahTimesBar.dart';

/// show all announcements in one after another
class AnnouncementScreen extends StatefulWidget {
  AnnouncementScreen({Key? key, this.onDone}) : super(key: key);

  final VoidCallback? onDone;

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  int index = -1;
  Announcement? activeAnnouncement;

  void nextAnnouncement() {
    if (!mounted) return;

    final allAnnouncements = context.read<MosqueManager>().activeAnnouncements;
    index++;

    if (index >= allAnnouncements.length) {
      Future.delayed(Duration(milliseconds: 80), widget.onDone);
      return;
    }

    setState(() {
      activeAnnouncement = allAnnouncements[index];
    });

    if (activeAnnouncement!.video == null) {
      Future.delayed(
        Duration(seconds: activeAnnouncement!.duration ?? 30),
        nextAnnouncement,
      );
    }
  }

  @override
  void initState() {
    nextAnnouncement();
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
    if (activeAnnouncement!.content != null) {
      return textAnnouncement(
        activeAnnouncement!.content!,
        activeAnnouncement!.title,
      );
    } else if (activeAnnouncement!.image != null) {
      return imageAnnouncement(activeAnnouncement!.image!);
    } else if (activeAnnouncement!.video != null) {
      return videoAnnouncement(activeAnnouncement!.video!);
    }

    return SizedBox();
  }

  Widget textAnnouncement(String content, String? title) {
    return Padding(
      key: ValueKey("$content $title"),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          // title
          SizedBox(height: 2.vh),
          Text(
            title ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              shadows: kAnnouncementTextShadow,
              fontSize: 50,
              fontWeight: FontWeight.bold,
              fontFamily: StringManager.getFontFamilyByString(title ?? ''),
              color: Colors.amber,
              letterSpacing: 1,
            ),
          ).animate().slide().addRepaintBoundary(),
          // content
          SizedBox(height: 3.vh),
          Expanded(
            child: AutoSizeText(
              content,
              stepGranularity: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                shadows: kAnnouncementTextShadow,
                fontSize: 62,
                fontWeight: FontWeight.bold,
                fontFamily: StringManager.getFontFamilyByString(content),
                color: Colors.white,
                letterSpacing: 1,
              ),
            ).animate().fade(delay: 500.milliseconds).addRepaintBoundary(),
          ),
          SizedBox(
            height: 15.vh,
          ),
        ],
      ),
    );
  }

  Widget imageAnnouncement(String image) {
    return CachedNetworkImage(
      imageUrl: image,
      fit: BoxFit.cover,
    ).animate().slideX().addRepaintBoundary();
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
          onEnded: (metaData) => nextAnnouncement(),
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
