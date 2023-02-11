import 'package:flutter/material.dart';
import 'package:mawaqit/src/developer_mode/AnnouncementTest.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/pages/LanguageScreen.dart';
import 'package:mawaqit/src/pages/MosqueSearchScreen.dart';
import 'package:mawaqit/src/pages/developer/widgets/selector_widget.dart';
import 'package:mawaqit/src/pages/home/OfflineHomeScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AdhanSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AfterAdhanHadithSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AfterSalahAzkarScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/IqamaSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/IqamaaCountDownSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/JummuaLive.dart';
import 'package:mawaqit/src/pages/home/sub_screens/JumuaHadithSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/RandomHadithScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';

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
  afterSalahAzkarScreen,

  // jumuaa subScreen
  jumuaaLiveScreen,
  jumuaaScreen;

  String get readableName {
    switch (this) {
      case _ScreenState.jumuaaScreen:
        return 'Jumuaa Azkar Screen';
      case _ScreenState.normalScreen:
        return 'Normal Screen';
      case _ScreenState.announcementScreen:
        return 'Announcement Screen';
      case _ScreenState.randomHadithScreen:
        return 'Random Hadith Screen';
      case _ScreenState.adhanScreen:
        return 'Adhan Screen';
      case _ScreenState.afterAdhanDuaaScreen:
        return 'After Adhan Duaa Screen';
      case _ScreenState.iqamaaCountDownScreen:
        return 'Iqamaa Count Down Screen';
      case _ScreenState.iqamaaScreen:
        return 'Iqamaa Screen';
      case _ScreenState.jumuaaLiveScreen:
        return 'Jumuaa Live Screen';
      case _ScreenState.afterSalahAzkarScreen:
        return 'After Salah Azkar Screen';
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
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          title: 'Tap',
          options: [
            SelectorOption(
              title: 'Change language',
              onSelect: () => AppRouter.push(LanguageScreen()),
            ),
            SelectorOption(
              title: 'Change mosque',
              onSelect: () => AppRouter.push(MosqueSearchScreen()),
            ),
            SelectorOption(
              title: "Force screen",
              subOptions: [
                SelectorOption(
                  title: 'Clear',
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
          ],
        ),
      ),
    );
  }
}
