import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mawaqit/src/enum/home_active_screen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AdhanSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AfterAdhanHadithSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AfterSalahAzkarScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/IqamaSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/IqamaaCountDownSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/JummuaLive.dart';
import 'package:mawaqit/src/pages/home/sub_screens/JumuaHadithSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/RandomHadithScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/widgets/MawaqitDrawer.dart';
import 'package:provider/provider.dart';

import 'sub_screens/AnnouncementScreen.dart';

class OfflineHomeScreen extends StatelessWidget {
  OfflineHomeScreen({Key? key}) : super(key: key);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.watch<MosqueManager>();

    if (mosqueProvider.mosque == null || mosqueProvider.times == null) return SizedBox();

    final mosque = mosqueProvider.mosque!;

    return CallbackShortcuts(
      bindings: {
        SingleActivator(LogicalKeyboardKey.arrowLeft): () => _scaffoldKey.currentState?.openDrawer(),
        SingleActivator(LogicalKeyboardKey.arrowRight): () => _scaffoldKey.currentState?.openDrawer(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          key: _scaffoldKey,
          drawer: MawaqitDrawer(goHome: () => Navigator.pop(context)),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: mosque.image != null
                    ? NetworkImage(mosque.image!) as ImageProvider
                    : AssetImage('assets/backgrounds/splash_screen_5.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black54,
              child: subScreen(mosqueProvider.state),
            ),
          ),
        ),
      ),
    );
  }

  Widget subScreen(HomeActiveScreen state) {
    switch (state) {
      case HomeActiveScreen.normal:
        return NormalHomeSubScreen();
      case HomeActiveScreen.adhan:
        return AdhanSubScreen();
      case HomeActiveScreen.afterAdhanHadith:
        return AfterAdhanSubScreen();
      case HomeActiveScreen.iqamaaCountDown:
        return IqamaaCountDownSubScreen();
      case HomeActiveScreen.iqamaa:
        return IqamaSubScreen();
      case HomeActiveScreen.afterSalahAzkar:
        return AfterSalahAzkar();
      case HomeActiveScreen.randomHadith:
        return RandomHadithScreen();
      case HomeActiveScreen.jumuaaHadith:
        return JumuaHadithSubScreen();
      case HomeActiveScreen.announcementScreen:
        return AnnouncementScreen();
      case HomeActiveScreen.jumuaaLiveScreen:
        return JummuaLive();
        break;
    }
    return SizedBox();
  }
}
