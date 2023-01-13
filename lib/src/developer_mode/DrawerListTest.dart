import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mawaqit/src/helpers/HiveLocalDatabase.dart';
import 'package:provider/provider.dart';

import '../../AnnouncementTest.dart';
import '../../TestSubScreens.dart';
import '../elements/DrawerListTitle.dart';
import '../enum/home_active_screen.dart';
import '../helpers/AppRouter.dart';
import '../pages/home/OfflineHomeScreen.dart';
import '../pages/home/sub_screens/JummuaLive.dart';

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
            text: "Offline home",
            onTap: () async {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OfflineHomeScreen(),
                  ));
            }),
        /////////////// drawer test////////////////
        DrawerListTitle(
          icon: Icons.timer_rounded,
          text: "Prayer Times ",
          onTap: () {
            AppRouter.popAndPush(TestSubScreens(
              state: HomeActiveScreen.normal,
            ));
          },
        ),
        DrawerListTitle(
          icon: Icons.notifications,
          text: "Alert",
          onTap: () {
            AppRouter.popAndPush(TestSubScreens(
              state: HomeActiveScreen.adhan,
            ));
          },
        ),
        DrawerListTitle(
          icon: Icons.countertops_rounded,
          text: " Iqama Count Down  ",
          onTap: () => AppRouter.popAndPush(
            TestSubScreens(state: HomeActiveScreen.iqamaaCountDown),
          ),
        ),
        DrawerListTitle(
          icon: Icons.next_plan_rounded,
          text: " After Adahn Hadith  ",
          onTap: () => AppRouter.popAndPush(
            TestSubScreens(state: HomeActiveScreen.afterAdhanHadith),
          ),
        ),
        DrawerListTitle(
          icon: Icons.front_hand_rounded,
          text: " After Salah Azkar  ",
          onTap: () => AppRouter.popAndPush(
            TestSubScreens(state: HomeActiveScreen.afterSalahAzkar),
          ),
        ),
        DrawerListTitle(
          icon: Icons.mic_external_on,
          text: " Iqama",
          onTap: () => AppRouter.popAndPush(
            TestSubScreens(state: HomeActiveScreen.iqamaa),
          ),
        ),
        DrawerListTitle(
          icon: Icons.message_outlined,
          text: " JumuaaHadith  ",
          onTap: () => AppRouter.popAndPush(
            TestSubScreens(state: HomeActiveScreen.jumuaaHadith),
          ),
        ),
        DrawerListTitle(
          icon: Icons.message_outlined,
          text: " Random Hadith ",
          onTap: () => AppRouter.popAndPush(
            TestSubScreens(state: HomeActiveScreen.randomHadith),
          ),
        ),
        DrawerListTitle(
          icon: Icons.notifications,
          text: " Announcement ",
          onTap: () => AppRouter.popAndPush(
            AnnouncementTest(),
          ),
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
