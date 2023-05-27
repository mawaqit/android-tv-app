import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/mawaqit_image/mawaqit_network_image.dart';
import 'package:mawaqit/src/models/announcement.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';
import 'package:mawaqit/src/pages/home/widgets/AboveSalahBar.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../helpers/StringUtils.dart';
import '../widgets/SalahTimesBar.dart';

/// show all announcements in one after another
class AnnouncementScreen extends StatefulWidget {
  AnnouncementScreen({
    Key? key,
    this.onDone,
    this.enableVideos = true,
  }) : super(key: key);

  final VoidCallback? onDone;

  /// used to disable videos on mosques
  final bool enableVideos;

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  int index = -1;
  Announcement? activeAnnouncement;

  void nextAnnouncement() {
    if (!mounted) return;

    final mosqueManager = context.read<MosqueManager>();
    final allAnnouncements = mosqueManager.activeAnnouncements(widget.enableVideos);
    index++;

    if (index >= allAnnouncements.length) {
      Future.delayed(Duration(milliseconds: 80), widget.onDone);
    }

    setState(() {
      activeAnnouncement = allAnnouncements[index % allAnnouncements.length];
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
    final announcements = context.read<MosqueManager>().activeAnnouncements(widget.enableVideos);

    if (announcements.isEmpty) return NormalHomeSubScreen();

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        announcementWidgets(),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 1.vh),
            child: AboveSalahBar(),
          ),
        ),
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
      return _TextAnnouncement(
        content: activeAnnouncement!.content!,
        title: activeAnnouncement!.title,
      );
    } else if (activeAnnouncement!.image != null) {
      return _ImageAnnouncement(image: activeAnnouncement!.image!);
    } else if (activeAnnouncement!.video != null) {
      return _VideoAnnouncement(
        key: ValueKey(activeAnnouncement!.video),
        url: activeAnnouncement!.video!,
        onEnded: nextAnnouncement,
      );
    }

    return SizedBox();
  }
}

class _TextAnnouncement extends StatelessWidget {
  const _TextAnnouncement({Key? key, required this.title, required this.content}) : super(key: key);

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey("$content $title"),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          // title
          SizedBox(height: 10.vh),
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
                fontSize: 8.vw,
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

  get kAnnouncementTextShadow => [
        Shadow(
          offset: Offset(0, 9),
          blurRadius: 15,
          color: Colors.black54,
        ),
      ];
}

class _ImageAnnouncement extends StatelessWidget {
  const _ImageAnnouncement({Key? key, required this.image}) : super(key: key);

  final String image;

  @override
  Widget build(BuildContext context) {
    return MawaqitNetworkImage(
      imageUrl: image,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    ).animate().slideX().addRepaintBoundary();
  }
}

class _VideoAnnouncement extends StatefulWidget {
  const _VideoAnnouncement({
    Key? key,
    required this.url,
    this.onEnded,
  }) : super(key: key);

  final String url;
  final VoidCallback? onEnded;

  @override
  State<_VideoAnnouncement> createState() => _VideoAnnouncementState();
}

class _VideoAnnouncementState extends State<_VideoAnnouncement> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    final mosqueManager = context.read<MosqueManager>();

    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.url)!,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: mosqueManager.typeIsMosque,
        useHybridComposition: false,
        hideControls: true,
        forceHD: true,
      ),
    );

    /// if announcement didn't started playing after 20 seconds skip it
    Future.delayed(20.seconds, () {
      if (_controller.value.isReady == false) widget.onEnded?.call();
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        onEnded: (metaData) => widget.onEnded?.call(),
      ),
    );
  }
}
