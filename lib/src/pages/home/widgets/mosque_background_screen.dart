import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/HexColor.dart';
import 'package:mawaqit/src/pages/home/OfflineHomeScreen.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/widgets/MawaqitDrawer.dart';
import 'package:provider/provider.dart';

/// used to show the background of the mosque
/// used with the sunscreens
/// in case you need to show sub screen without the [OfflineHomeScreen]
class MosqueBackgroundScreen extends StatelessWidget {
  MosqueBackgroundScreen({Key? key, required this.child}) : super(key: key);

  final Widget child;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.watch<MosqueManager>();
    final mosqueConfig = mosqueProvider.mosqueConfig;

    if (!mosqueProvider.loaded) return SizedBox();

    return CallbackShortcuts(
      bindings: {
        SingleActivator(LogicalKeyboardKey.arrowLeft): () => _scaffoldKey.currentState?.openDrawer(),
        SingleActivator(LogicalKeyboardKey.arrowRight): () => _scaffoldKey.currentState?.openDrawer(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          key: _scaffoldKey,
          drawer: MawaqitDrawer(goHome: () => AppRouter.popAll()),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: mosqueConfig!.backgroundType == "color"
                ? BoxDecoration(color: HexColor(mosqueConfig.backgroundColor))
                : BoxDecoration(
                    image: DecorationImage(
                      image: mosqueConfig.backgroundMotif == "0"
                          ? NetworkImage(mosqueProvider.mosque?.exteriorPicture ?? "")
                          : mosqueConfig.backgroundMotif == "-1"
                              ? NetworkImage(mosqueProvider.mosque?.interiorPicture ?? "")
                              : NetworkImage(
                                  "https://mawaqit.net/bundles/app/prayer-times/img/background/${mosqueConfig.backgroundMotif ?? 5}.jpg"),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {},
                    ),
                  ),
            child: Container(child: child),
          ),
        ),
      ),
    );
  }
}
