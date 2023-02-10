import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/HiveLocalDatabase.dart';
import 'package:mawaqit/src/pages/HomeScreen.dart';
import 'package:provider/provider.dart';

import 'AnnouncementTest.dart';
import '../elements/DrawerListTitle.dart';
import '../helpers/AppRouter.dart';
import '../pages/home/sub_screens/AdhanSubScreen.dart';
import '../pages/home/sub_screens/AfterAdhanHadithSubScreen.dart';
import '../pages/home/sub_screens/AfterSalahAzkarScreen.dart';
import '../pages/home/sub_screens/IqamaSubScreen.dart';
import '../pages/home/sub_screens/IqamaaCountDownSubScreen.dart';
import '../pages/home/sub_screens/JummuaLive.dart';
import '../pages/home/sub_screens/JumuaHadithSubScreen.dart';
import '../pages/home/sub_screens/RandomHadithScreen.dart';
import '../pages/home/sub_screens/normal_home.dart';
import '../pages/home/widgets/mosque_background_screen.dart';
import 'RandomHadithTest.dart';

class DrawerListDeveloper extends StatelessWidget {
  const DrawerListDeveloper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hive = context.watch<HiveManager>();
    return ListView(
      shrinkWrap: true,
      primary: false,
      children: [
        DrawerListTitle(
            icon: Icons.home_filled,
            text: "Online home",
            onTap: () async {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MosqueBackgroundScreen(child: HomeScreen()),
                  ));
            }),
        /////////////// drawer test////////////////
        DrawerListTitle(
          icon: Icons.timer_rounded,
          text: "Prayer Times ",
          onTap: () {
            AppRouter.popAndPush(MosqueBackgroundScreen(
              child: NormalHomeSubScreen(),
            ));
          },
        ),
        DrawerListTitle(
          icon: Icons.notifications,
          text: "Alert",
          onTap: () {
            AppRouter.popAndPush(MosqueBackgroundScreen(
              child: AdhanSubScreen(),
            ));
          },
        ),
        DrawerListTitle(
          icon: Icons.countertops_rounded,
          text: " Iqama Count Down  ",
          onTap: () => AppRouter.popAndPush(MosqueBackgroundScreen(
            child: IqamaaCountDownSubScreen(),
          )),
        ),
        DrawerListTitle(
          icon: Icons.next_plan_rounded,
          text: " After Adahn Hadith  ",
          onTap: () => AppRouter.popAndPush(MosqueBackgroundScreen(
            child: AfterAdhanSubScreen(),
          )),
        ),
        DrawerListTitle(
          icon: Icons.front_hand_rounded,
          text: " After Salah Azkar  ",
          onTap: () => AppRouter.popAndPush(MosqueBackgroundScreen(
            child: AfterSalahAzkar(),
          )),
        ),
        DrawerListTitle(
          icon: Icons.mic_external_on,
          text: " Iqama",
          onTap: () => AppRouter.popAndPush(MosqueBackgroundScreen(
            child: IqamaSubScreen(),
          )),
        ),
        DrawerListTitle(
          icon: Icons.message_outlined,
          text: " JumuaaHadith  ",
          onTap: () => AppRouter.popAndPush(MosqueBackgroundScreen(
            child: JumuaHadithSubScreen(),
          )),
        ),
        DrawerListTitle(
          icon: Icons.message_outlined,
          text: " Random Hadith ",
          onTap: () => AppRouter.popAndPush(MosqueBackgroundScreen(
            child: RandomHadithTest(),
          )),
        ),
        DrawerListTitle(
          icon: Icons.notifications,
          text: " Announcement ",
          onTap: () => AppRouter.popAndPush(MosqueBackgroundScreen(
            child: AnnouncementTest(),
          )),
        ),
        DrawerListTitle(
          icon: Icons.live_tv,
          text: " Jumua live ",
          onTap: () => AppRouter.popAndPush(
            JummuaLive(),
          ),
        ),
        SwitchListTile(
          secondary: Icon(Icons.tv),
          value: hive.isSecondaryScreen(),
          onChanged: (bool value) {
            hive.putIsSecondaryScreen(value);
          },
          title: Text("Show secondary screen"),
        ),

        Divider(
          color: Colors.grey,
        ),
      ],
    );
  }
}
