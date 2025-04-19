import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/widgets/MawaqitDrawer.dart';
import 'package:provider/provider.dart';

/// Javascript version of the app
class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final appLanguage = context.read<AppLanguage>();

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
      child: Scaffold(
        key: _scaffoldKey,
        drawer: MawaqitDrawer(goHome: () => AppRouter.pop()),
        body: Container(),
      ),
    );
  }
}
