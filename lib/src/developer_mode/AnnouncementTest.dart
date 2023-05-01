import 'package:flutter/material.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AnnouncementScreen.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

class AnnouncementTest extends StatelessWidget {
  const AnnouncementTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();

    if (mosqueManager.activeAnnouncements(true).isEmpty) {
      return Center(
        child: Text("There are no announcement for this mosque"),
      );
    }

    return AnnouncementScreen(
      enableVideos: !mosqueManager.typeIsMosque,
    );
  }
}
