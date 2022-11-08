import 'package:flutter/material.dart';
import 'package:mawaqit/src/enum/home_active_screen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AdhanSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AfterAdhanHadithSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AfterSalahAzkarScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/IqamaSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/IqamaaCountDownSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/JumuaHadithSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/RandomHadithScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

class OfflineHomeScreen extends StatelessWidget {
  const OfflineHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.watch<MosqueManager>();

    //todo handle this case
    if (mosqueProvider.mosque == null || mosqueProvider.times == null) return SizedBox();

    final mosque = mosqueProvider.mosque!;

    return Scaffold(
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
    }
    return SizedBox();
  }
}
