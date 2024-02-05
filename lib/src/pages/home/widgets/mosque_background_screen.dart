import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/HexColor.dart';
import 'package:mawaqit/src/mawaqit_image/mawaqit_image_cache.dart';
import 'package:mawaqit/src/pages/home/OfflineHomeScreen.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/widgets/MawaqitDrawer.dart';
import 'package:provider/provider.dart';

/// used to show the background of the mosque
/// used with the sunscreens
/// in case you need to show sub screen without the [OfflineHomeScreen]
class MosqueBackgroundScreen extends StatefulWidget {
  MosqueBackgroundScreen({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<MosqueBackgroundScreen> createState() => _MosqueBackgroundScreenState();
}

class _MosqueBackgroundScreenState extends State<MosqueBackgroundScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.watch<MosqueManager>();
    final mosqueConfig = mosqueProvider.mosqueConfig;

    if (!mosqueProvider.loaded) return SizedBox();

    return RawKeyboardListener(
       focusNode: FocusNode(),
       onKey: (event) {
         if (event is RawKeyDownEvent) {
           if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
               event.logicalKey == LogicalKeyboardKey.arrowUp ||
               event.logicalKey == LogicalKeyboardKey.arrowLeft ||
               event.logicalKey == LogicalKeyboardKey.arrowRight) {
             _scaffoldKey.currentState?.openDrawer();
           }
         }
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
                          ? MawaqitNetworkImageProvider(mosqueProvider.mosque?.interiorPicture ?? "")
                          : mosqueConfig.backgroundMotif == "-1"
                              ? MawaqitNetworkImageProvider(mosqueProvider.mosque?.exteriorPicture ?? "")
                              : MawaqitNetworkImageProvider(mosqueProvider.mosqueConfig!.motifUrl),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(.4),
                        BlendMode.srcOver,
                      ),
                      onError: (exception, stackTrace) {},
                    ),
                  ),
            child: RepaintBoundary(child: widget.child),
          ),
        ),
      ),
    );
  }
}
