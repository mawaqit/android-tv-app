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
import 'package:provider/provider.dart';

enum _ScreenState {
  // home normal subScreen
  normalScreen,
  announcementScreen,
  randomHadithScreen,

  // Adhan subScreens
  adhanScreen,
  afterAdhanDuaaScreen,
  iqamaaCountDownScreen,
  iqamaaScreen,
  duaaBetweenAdhanAndIqamaaScreen,
  afterSalahAzkarScreen,
  fajrWakeUpScreen,
  duaaEftarScreen,

  // jumuaa subScreen
  jumuaaLiveScreen,
  jumuaaScreen;

  String get readableName {
    switch (this) {
      case _ScreenState.jumuaaScreen:
        return S.current.jumuaaLive;
      case _ScreenState.normalScreen:
        return S.current.normalScreen;
      case _ScreenState.announcementScreen:
        return S.current.announcement;
      case _ScreenState.randomHadithScreen:
        return S.current.randomHadith;
      case _ScreenState.adhanScreen:
        return S.current.alAdhan;
      case _ScreenState.afterAdhanDuaaScreen:
        return S.current.afterAdhanHadith;
      case _ScreenState.duaaBetweenAdhanAndIqamaaScreen:
        return S.current.duaaBetweenSalahAndAdhan;
      case _ScreenState.duaaEftarScreen:
        return S.current.duaaElEftar;
      case _ScreenState.iqamaaCountDownScreen:
        return S.current.duaaRemainder;
      case _ScreenState.iqamaaScreen:
        return S.current.iqamaa;
      case _ScreenState.jumuaaLiveScreen:
        return S.current.jumuaaLive;
      case _ScreenState.fajrWakeUpScreen:
        return S.current.fajrWakeUp;
      case _ScreenState.afterSalahAzkarScreen:
        return S.current.afterSalahAzkar;
    }
  }
}

/// this screen made to speed up the development process
/// user can force to use specific screen
/// user can change mosque language or mosque from the screen
class DeveloperScreen extends StatefulWidget {
  const DeveloperScreen({Key? key}) : super(key: key);

  @override
  State<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen> {
  _ScreenState? forcedScreen;

  Widget? get subScreen {
    switch (forcedScreen) {
      case _ScreenState.normalScreen:
        return NormalHomeSubScreen();
      case _ScreenState.announcementScreen:
        return AnnouncementTest();
      case _ScreenState.randomHadithScreen:
        return RandomHadithScreen();
      case _ScreenState.adhanScreen:
        return AdhanSubScreen();
      case _ScreenState.afterAdhanDuaaScreen:
        return AfterAdhanSubScreen();
      case _ScreenState.iqamaaCountDownScreen:
        return IqamaaCountDownSubScreen();
      case _ScreenState.iqamaaScreen:
        return IqamaSubScreen();
      case _ScreenState.afterSalahAzkarScreen:
        return AfterSalahAzkar();
      case _ScreenState.jumuaaScreen:
        return JumuaHadithSubScreen();
      case _ScreenState.jumuaaLiveScreen:
        return JummuaLive();
      case _ScreenState.duaaBetweenAdhanAndIqamaaScreen:
        return DuaaBetweenAdhanAndIqamaaScreen();
      case _ScreenState.fajrWakeUpScreen:
        return FajrWakeUpSubScreen();
      case _ScreenState.duaaEftarScreen:
        return DuaaEftarScreen();
      default:
        return null;
    }
  }

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
            child: subScreen ?? OfflineHomeScreen(),
          ),
          menuSelector(),
          if (forcedScreen != null)
            Align(
              alignment: Alignment.topCenter,
              child: Text(forcedScreen!.readableName),
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
                ..._ScreenState.values.map(
                  (e) => SelectorOption(
                    title: e.readableName,
                    onSelect: () => setState(() => forcedScreen = e),
                  ),
                ),
              ],
            ),
            SelectorOption(
              title: S.of(context).changeTheme,
              onSelect: () => context.read<ThemeNotifier>().toggleMode(),
            ),
          ],
        ),
      ),
    );
  }
}
