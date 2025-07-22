import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/pages/HomeScreen.dart';
import 'package:mawaqit/src/pages/developer/DeveloperScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/DuaaBetweenAdhanAndIqama.dart';
import 'package:mawaqit/src/pages/home/sub_screens/DuaaEftarScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/takberat_aleid_screen.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:provider/provider.dart';

import '../elements/DrawerListTitle.dart';
import '../helpers/AppRouter.dart';
import '../pages/home/sub_screens/AdhanSubScreen.dart';
import '../pages/home/sub_screens/AfterAdhanHadithSubScreen.dart';
import '../pages/home/sub_screens/AfterSalahAzkarScreen.dart';
import '../pages/home/sub_screens/DuaaBetweenAdhanAndIqama.dart';
import '../pages/home/sub_screens/IqamaSubScreen.dart';
import '../pages/home/sub_screens/IqamaaCountDownSubScreen.dart';
import '../pages/home/sub_screens/JummuaLive.dart';
import '../pages/home/sub_screens/JumuaHadithSubScreen.dart';
import '../pages/home/sub_screens/RandomHadithScreen.dart';
import '../pages/home/sub_screens/normal_home.dart';
import '../pages/home/widgets/mosque_background_screen.dart';
import 'AnnouncementTest.dart';

class DrawerListDeveloper extends StatelessWidget {
  const DrawerListDeveloper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userPreferencesManager = Provider.of<UserPreferencesManager>(context);

    return ListView(
      shrinkWrap: true,
      primary: false,
      children: [
        DrawerListTitle(
            icon: Icons.developer_mode_rounded,
            text: S.of(context).developersHomeScreen,
            onTap: () async {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MosqueBackgroundScreen(child: DeveloperScreen()),
                  ));
            }),

        DrawerListTitle(
            icon: Icons.home_filled,
            text: S.of(context).onlineHome,
            onTap: () async {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MosqueBackgroundScreen(child: HomeScreen()),
                  ));
            }),
        DrawerListTitle(
          icon: Icons.timer_rounded,
          text: S.of(context).duaaBetweenAdhanAndIqamaaTitle,
          onTap: () {
            AppRouter.popAndPush(
              MosqueBackgroundScreen(
                child: DuaaBetweenAdhanAndIqamaaScreen(),
              ),
            );
          },
        ),
        /////////////// drawer test////////////////
        DrawerListTitle(
          icon: Icons.timer_rounded,
          text: S.of(context).prayerTimes,
          onTap: () {
            AppRouter.popAndPush(MosqueBackgroundScreen(
              child: NormalHomeSubScreen(),
            ));
          },
        ),
        DrawerListTitle(
          icon: Icons.timer_rounded,
          text: S.of(context).eidMubarak,
          onTap: () {
            AppRouter.popAndPush(
              MosqueBackgroundScreen(
                child: TakberatAleidScreen(),
              ),
            );
          },
        ),
        DrawerListTitle(
          icon: Icons.timer_rounded,
          text: S.of(context).duaaElEftar,
          onTap: () {
            AppRouter.popAndPush(
              MosqueBackgroundScreen(
                child: DuaaEftarScreen(),
              ),
            );
          },
        ),
        DrawerListTitle(
          icon: Icons.timer_rounded,
          text: S.of(context).duaBetweenAdhanIqamah,
          onTap: () {
            AppRouter.popAndPush(
              MosqueBackgroundScreen(
                child: DuaaBetweenAdhanAndIqamaaScreen(),
              ),
            );
          },
        ),
        DrawerListTitle(
          icon: Icons.notifications,
          text: S.of(context).alAdhan,
          onTap: () {
            AppRouter.popAndPush(MosqueBackgroundScreen(
              child: AdhanSubScreen(),
            ));
          },
        ),
        DrawerListTitle(
          icon: Icons.countertops_rounded,
          text: S.of(context).iqamaaCountDown,
          onTap: () => AppRouter.popAndPush(MosqueBackgroundScreen(
            child: IqamaaCountDownSubScreen(),
          )),
        ),
        DrawerListTitle(
          icon: Icons.next_plan_rounded,
          text: S.of(context).afterAdhanHadith,
          onTap: () => AppRouter.popAndPush(MosqueBackgroundScreen(
            child: AfterAdhanSubScreen(),
          )),
        ),
        DrawerListTitle(
          icon: Icons.front_hand_rounded,
          text: S.of(context).afterSalahAzkar,
          onTap: () => AppRouter.popAndPush(MosqueBackgroundScreen(
            child: AfterSalahAzkar(),
          )),
        ),
        DrawerListTitle(
          icon: Icons.mic_external_on,
          text: S.of(context).iqama,
          onTap: () => AppRouter.popAndPush(MosqueBackgroundScreen(
            child: IqamaSubScreen(),
          )),
        ),
        DrawerListTitle(
          icon: Icons.message_outlined,
          text: S.of(context).jumua,
          onTap: () => AppRouter.popAndPush(MosqueBackgroundScreen(
            child: JumuaHadithSubScreen(),
          )),
        ),
        DrawerListTitle(
          icon: Icons.message_outlined,
          text: S.of(context).randomHadith,
          onTap: () => AppRouter.popAndPush(MosqueBackgroundScreen(
            child: DebugRandomHadithWrapper(),
          )),
        ),
        DrawerListTitle(
          icon: Icons.notifications,
          text: S.of(context).announcement,
          onTap: () => AppRouter.popAndPush(MosqueBackgroundScreen(
            child: AnnouncementTest(),
          )),
        ),
        DrawerListTitle(
          icon: Icons.live_tv,
          text: S.of(context).jumuaaLive,
          onTap: () => AppRouter.popAndPush(
            MosqueBackgroundScreen(child: JummuaLive()),
          ),
        ),

        SwitchListTile(
          value: userPreferencesManager.forceStaging,
          onChanged: (value) => userPreferencesManager.forceStaging = value,
          title: Text(S.of(context).forceStaging),
        ),
        Divider(
          color: Colors.grey,
        ),
      ],
    );
  }
}
