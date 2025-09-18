import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/developer_mode/AnnouncementTest.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/StreamGenerator.dart';
import 'package:mawaqit/src/pages/LanguageScreen.dart';
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
import 'package:mawaqit/src/pages/home/widgets/workflows/repeating_workflow_widget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/theme_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/src/state_management/random_hadith/random_hadith_notifier.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:mawaqit/i18n/AppLanguage.dart';

import '../../../main.dart';

typedef ForcedScreen = ({WidgetBuilder builder, String name});

typedef TestMosque = ({String name, String uuid});

const _HadithRepeatDuration = Duration(minutes: 4);

/// Debug wrapper for RandomHadithScreen that includes the 4-minute timing mechanism
class DebugRandomHadithWrapper extends ConsumerStatefulWidget {
  const DebugRandomHadithWrapper({Key? key}) : super(key: key);

  @override
  ConsumerState<DebugRandomHadithWrapper> createState() => _DebugRandomHadithWrapperState();
}

class _DebugRandomHadithWrapperState extends ConsumerState<DebugRandomHadithWrapper> {
  Timer? _hadithRefreshTimer;
  Widget _currentWidget = Container();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _startHadithFlow();
    });
  }

  void _startHadithFlow() {
    // Show RandomHadithScreen immediately
    _showRandomHadith();

    // Set up timer to refresh hadith content every 4 minutes (like in production RepeatingWorkflowItem)
    _hadithRefreshTimer = Timer.periodic(_HadithRepeatDuration, (timer) {
      if (mounted) {
        _refreshHadithContent();
      }
    });
  }

  void _showRandomHadith() {
    if (mounted) {
      setState(() {
        _currentWidget = RandomHadithScreen(
          onDone: () {
            // onDone callback - matches behavior in normal workflow
          },
        );
      });
    }
  }

  void _refreshHadithContent() {
    if (mounted) {
      final hadith = provider_pkg.Provider.of<AppLanguage>(context, listen: false).hadithLanguage;
      final language = hadith.isEmpty ? 'ar' : hadith;
      ref.read(randomHadithNotifierProvider.notifier).getRandomHadith(language: language);
    }
  }

  @override
  void dispose() {
    _hadithRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _currentWidget;
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
  ForcedScreen? forcedScreen;
  StreamSubscription? walkThrowScreensSubscription;

  static const testMosques = <TestMosque>[
    (name: "Test Mosque", uuid: "8e8a41cf-62d4-4890-9454-120d27b229e1"),
    (name: "Mosquee El Falah", uuid: "6e8cc6b6-901a-4271-a5f7-818a1fa20a34"),
    (name: "Mosquee Le Grand Quevilly", uuid: "dbfd7ccf-70da-49f3-93a9-a4a7e8cccf04"),
    (name: "[Staging] TEST ISTANBUL (10149)", uuid: "626cf81c-ebf1-4f4f-8ad0-5fc840f9c14b"),
  ];

  List<ForcedScreen> get screens => [
        (builder: (context) => NormalHomeSubScreen(), name: S.current.normalScreen),
        (builder: (context) => AnnouncementTest(), name: S.current.announcement),
        (builder: (context) => DebugRandomHadithWrapper(), name: S.current.randomHadith),
        (builder: (context) => AdhanSubScreen(), name: S.current.alAdhan),
        (builder: (context) => AfterAdhanSubScreen(), name: S.current.afterAdhanHadith),
        (builder: (context) => DuaaBetweenAdhanAndIqamaaScreen(), name: S.current.duaaRemainder),
        (builder: (context) => IqamaaCountDownSubScreen(isDebug: true), name: S.current.iqamaaCountDown),
        (builder: (context) => IqamaSubScreen(), name: S.current.iqama),
        (builder: (context) => AfterSalahAzkar(), name: S.current.afterSalahAzkar),
        (builder: (context) => JumuaHadithSubScreen(), name: S.current.jumua),
        (builder: (context) => JummuaLive(), name: S.current.jumuaaLive),
        (builder: (context) => FajrWakeUpSubScreen(), name: S.current.fajrWakeUp),
        (builder: (context) => DuaaEftarScreen(), name: S.current.duaaElEftar),
      ];

  forceScreen(ForcedScreen e) {
    cancelWalkThrowScreens();
    if (mounted) {
      setState(() {
        forcedScreen = e;
      });
    }
  }

  void cancelWalkThrowScreens() {
    walkThrowScreensSubscription?.cancel();
    if (mounted) {
      setState(() {
        walkThrowScreensSubscription = null;
        forcedScreen = null; // clear the forcedScreen when canceling the walkthrough
      });
    } else {
      // If widget is not mounted, just clean up without setState
      walkThrowScreensSubscription = null;
      forcedScreen = null;
    }
  }

  void walkThrowScreens() {
    walkThrowScreensSubscription?.cancel();
    walkThrowScreensSubscription = generateStream(15.seconds).listen((event) {
      if (mounted) {
        setState(() {
          forcedScreen = screens[event % screens.length];
        });
      }
    });
  }

  changeMosque(String uuid) => context.read<MosqueManager>().fetchMosque(uuid).catchError((e) {});

  Future<bool> _clearDataAndRestartApp() async {
    try {
      final result = await MethodChannel('nativeMethodsChannel').invokeMethod('clearAppData');
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    // Just cancel the subscription without updating UI state since widget is being destroyed
    walkThrowScreensSubscription?.cancel();
    super.dispose();
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
              title: "Walkthrough screens",
              onSelect: walkThrowScreens,
            ),
            SelectorOption(
              title: "Change mosque ",
              subOptions: testMosques
                  .map((e) => SelectorOption(
                        title: e.name,
                        onSelect: () => changeMosque(e.uuid),
                      ))
                  .toList(),
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
                    onSelect: () => forceScreen(e),
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
            if (walkThrowScreensSubscription != null)
              SelectorOption(title: "Cancel walk through", onSelect: cancelWalkThrowScreens),
            SelectorOption(
              title: "Clear data & force close app",
              onSelect: () => _clearDataAndRestartApp(),
            ),
          ],
        ),
      ),
    );
  }
}
