import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../widgets/SalahTimesBar.dart';
import 'normal_home.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  int activeIndex = 0;
  bool showHome = true;
  Duration homeDuration = Duration(seconds: 30);
  Duration announcementDuration = Duration(seconds: 30);

  @override
  void initState() {
    Future.delayed(homeDuration).then((value) {
      nextScreen();
    });
    super.initState();

  }


  @override
  Widget build(BuildContext context) {

    if (showHome ||context.read<MosqueManager>().mosque!.announcements.length<=activeIndex) {
      return NormalHomeSubScreen();
    }
    return Stack(
      alignment:Alignment.bottomCenter,
      children: [
        announcementWidgets(),
        IgnorePointer(
          child: Padding(
            padding:  EdgeInsets.only(bottom:1.5.vh ),
            child: SalahTimesBar(miniStyle: true),
          ),
        )
      ],
    );
  }

  Widget announcementWidgets() {
    final announcement = context.read<MosqueManager>().mosque!.announcements[activeIndex];

    if (announcement.content != null) {
      return textAnnouncement(announcement.content!, announcement.title);
    } else if (announcement.image != null) {
      return imageAnnouncement(announcement.image!);
    } else if (announcement.video != null) {
      return videoAnnouncement(announcement.video!);
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
              fontFamily: 'hafs',
              color: Colors.amber,
                letterSpacing: 1

            )),
        // content
        Expanded(
          child: AutoSizeText(content,
              stepGranularity: 12,
              textAlign: TextAlign.center,
              style: TextStyle(

                shadows: kAnnouncementTextShadow,
                fontSize: 62,
                fontWeight: FontWeight.bold,
                fontFamily: 'hafs',
                color: Colors.white,
                letterSpacing: 1
              )),
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
          onEnded: (metaData) {
            nextScreen();
          },
          controller: _controller,
          showVideoProgressIndicator: true,
        ),

      ],
    );
  }

  nextScreen() {
    final announcement = context.read<MosqueManager>().mosque!.announcements;
    if (!showHome) {
      setState(() {
        showHome = true;
      });
      return Future.delayed(homeDuration).then(
        (value) => nextScreen(),
      );
    }

    setState(() {
      activeIndex++;
      if (activeIndex >= announcement.length) {
        activeIndex = 0;
      }
      showHome = false;
    });
    if (announcement[activeIndex].video == null)
      Future.delayed(announcementDuration).then(
        (value) => nextScreen(),
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
