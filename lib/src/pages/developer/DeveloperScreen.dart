import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/developer_mode/AnnouncementTest.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/pages/LanguageScreen.dart';
import 'package:mawaqit/src/pages/MosqueSearchScreen.dart';
import 'package:mawaqit/src/pages/developer/widgets/selector_widget.dart';
import 'package:mawaqit/src/pages/home/OfflineHomeScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AdhanSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AfterAdhanHadithSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AfterSalahAzkarScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/DuaaBetweenAdhanAndIqama.dart';
import 'package:mawaqit/src/pages/home/sub_screens/DuaaEftarScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/IqamaSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/IqamaaCountDownSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/JummuaLive.dart';
import 'package:mawaqit/src/pages/home/sub_screens/JumuaHadithSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/RandomHadithScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/fajr_wake_up_screen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/theme_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:provider/provider.dart';

typedef ForcedScreen = ({WidgetBuilder builder, String name});

/// this screen made to speed up the development process
/// user can force to use specific screen
/// user can change mosque language or mosque from the screen
class DeveloperScreen extends StatefulWidget {
  const DeveloperScreen({Key? key}) : super(key: key);

  @override
  State<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen> {
  ForcedScreen? forcedScreen;

  List<ForcedScreen> get screens => [
        (builder: (context) => NormalHomeSubScreen(), name: S.current.normalScreen),
        (builder: (context) => AnnouncementTest(), name: S.current.announcement),
        (builder: (context) => RandomHadithScreen(), name: S.current.randomHadith),
        (builder: (context) => AdhanSubScreen(), name: S.current.alAdhan),
        (builder: (context) => AfterAdhanSubScreen(), name: S.current.afterAdhanHadith),
        (builder: (context) => DuaaBetweenAdhanAndIqamaaScreen(), name: S.current.duaaRemainder),
        (builder: (context) => IqamaaCountDownSubScreen(), name: S.current.iqamaaCountDown),
        (builder: (context) => IqamaSubScreen(), name: S.current.iqama),
        (builder: (context) => AfterSalahAzkar(), name: S.current.afterSalahAzkar),
        (builder: (context) => JumuaHadithSubScreen(), name: S.current.jumua),
        (builder: (context) => JummuaLive(), name: S.current.jumuaaLive),
        (builder: (context) => FajrWakeUpSubScreen(), name: S.current.fajrWakeUp),
        (builder: (context) => DuaaEftarScreen(), name: S.current.duaaElEftar),
      ];

  @override
  Widget build(BuildContext context) {
    context.watch<MosqueManager>();

    return WillPopScope(
      onWillPop: () async {
        if (forcedScreen != null) {
          setState(() => forcedScreen = null);
          return false;
        }
        AppRouter.pop();
        return false;
      },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: forcedScreen?.builder(context) ?? OfflineHomeScreen(),
          ),
          menuSelector(),
          if (forcedScreen != null)
            Align(
              alignment: Alignment.topCenter,
              child: Text(forcedScreen!.name),
            ),
        ],
      ),
    );
  }

  Widget menuSelector() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 40),
        child: SelectorWidget(
          options: [
            SelectorOption(
              title: S.of(context).changeLanguage,
              onSelect: () => AppRouter.push(LanguageScreen()),
            ),
            SelectorOption(
              title: S.of(context).changeMosque,
              onSelect: () => AppRouter.push(MosqueSearchScreen()),
            ),
            SelectorOption(
              title: S.of(context).forceScreen,
              subOptions: [
                SelectorOption(
                  title: S.of(context).clear,
                  onSelect: () => setState(() => forcedScreen = null),
                ),
                ...screens.map(
                  (e) => SelectorOption(
                    title: e.name,
                    onSelect: () => setState(() => forcedScreen = e),
                  ),
                ),
              ],
            ),
            SelectorOption(
              title: S.of(context).changeTheme,
              onSelect: () => context.read<ThemeNotifier>().toggleMode(),
            ),
            SelectorOption(
              title: "Toggle orientation",
              onSelect: () => context.read<UserPreferencesManager>().toggleOrientation(),
            ),
          ],
        ),
      ),
    );
  }
}
