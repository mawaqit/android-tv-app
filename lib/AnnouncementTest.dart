import 'package:flutter/material.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AnnouncementScreen.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

class AnnouncementTest extends StatefulWidget {
  const AnnouncementTest({Key? key}) : super(key: key);

  @override
  State<AnnouncementTest> createState() => _AnnouncementTestState();
}

class _AnnouncementTestState extends State<AnnouncementTest> {
  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();

    if (mosqueManager.activeAnnouncements.isEmpty) {
      return Center(
        child: Text("There are no announcement for this mosque"),
      );
    }

    return AnnouncementScreen(
      key: ValueKey(activeIndex),
      index: activeIndex,
      onDone: () {
        setState(() {
          activeIndex++;
        });
      },
    );
  }
}
