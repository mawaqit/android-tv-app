import 'package:flutter/material.dart';
import 'package:mawaqit/src/enum/home_active_screen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

class OfflineHomeScreen extends StatelessWidget {
  const OfflineHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.watch<MosqueManager>();

    final mosque = mosqueProvider.mosque!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: mosque.image != null
                ? NetworkImage(mosque.image!) as ImageProvider
                : AssetImage('assets/backgrounds/splash_screen_5.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: subScreen(mosqueProvider.state),
      ),
    );
  }

  Widget subScreen(HomeActiveScreen state) {
    switch (state) {
      case HomeActiveScreen.normal:
        return NormalHomeSubScreen();

      case HomeActiveScreen.adhan:

      case HomeActiveScreen.afterAdhanHadith:

      case HomeActiveScreen.iqamaa:

      default:
        return SizedBox();
    }
  }
}
