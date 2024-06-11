import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/HexColor.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/widgets/MawaqitDrawer.dart';
import 'package:provider/provider.dart';

import '../../../const/constants.dart';

class MosqueBackgroundScreen extends StatefulWidget {
  final Widget child;

  const MosqueBackgroundScreen({Key? key, required this.child}) : super(key: key);

  @override
  State<MosqueBackgroundScreen> createState() => _MosqueBackgroundScreenState();
}

class _MosqueBackgroundScreenState extends State<MosqueBackgroundScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.watch<MosqueManager>();
    if (!mosqueProvider.loaded) return const SizedBox();
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: (event) {
        if (event is RawKeyDownEvent && event.isArrow) {
          _scaffoldKey.currentState?.openDrawer();
        }
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          key: _scaffoldKey,
          drawer: MawaqitDrawer(goHome: () => AppRouter.popAll()),
          body: _buildBackgroundDecoration(mosqueProvider),
        ),
      ),
    );
  }

  Widget _buildBackgroundDecoration(MosqueManager mosqueProvider) {
    final mosqueConfig = mosqueProvider.mosqueConfig!;
    if (mosqueConfig.backgroundType == "color") {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: HexColor(mosqueConfig.backgroundColor),
        child: RepaintBoundary(child: widget.child),
      );
    } else {
      String imageUrl = '';
      switch (mosqueConfig.backgroundMotif) {
        case "0":
          imageUrl = mosqueProvider.mosque?.interiorPicture ?? "";
          break;
        case "-1":
          imageUrl = mosqueProvider.mosque?.exteriorPicture ?? "";
          break;
        default:
          imageUrl = mosqueConfig.motifUrl;
      }
      return CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            child: RepaintBoundary(child: widget.child),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(.4), BlendMode.srcOver),
              ),
            ),
          );
        },
        placeholder: (context, url) {
          return Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), // Green color
              ),
            ),
          );
        },
        errorWidget: (context, url, error) => Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: RepaintBoundary(child: widget.child),
        ),
      );
    }
  }
}

extension on RawKeyDownEvent {
  bool get isArrow =>
      logicalKey == LogicalKeyboardKey.arrowDown ||
      logicalKey == LogicalKeyboardKey.arrowUp ||
      logicalKey == LogicalKeyboardKey.arrowLeft ||
      logicalKey == LogicalKeyboardKey.arrowRight;
}
