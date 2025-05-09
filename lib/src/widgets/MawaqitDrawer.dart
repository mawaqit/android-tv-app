import 'dart:developer';

import 'package:flutter/material.dart' hide Page;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ConsumerWidget, WidgetRef;
import 'package:flutter_svg/svg.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/elements/DrawerListTitle.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/pages/AboutScreen.dart';
import 'package:mawaqit/src/pages/quran/page/reciter_selection_screen.dart';
import 'package:mawaqit/src/routes/routes_constant.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/src/widgets/InfoWidget.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:mawaqit/src/developer_mode/DrawerListTest.dart';
import 'package:mawaqit/src/pages/SettingScreen.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';

import '../pages/quran/page/quran_mode_selection_screen.dart';
import 'package:mawaqit/src/pages/quran/reading/quran_reading_screen.dart';
import '../state_management/quran/quran/quran_state.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_store/open_store.dart';

class MawaqitDrawer extends ConsumerWidget {
  const MawaqitDrawer({Key? key, required this.goHome}) : super(key: key);

  final VoidCallback goHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPrefs = context.watch<UserPreferencesManager>();

    final theme = Theme.of(context);

    return Drawer(
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(0.0),
            children: <Widget>[
              Focus(child: SizedBox()),
              Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(bottom: 10),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            SvgPicture.asset(
                              R.ASSETS_SVG_MAWAQIT_LOGO_LIGHT_SVG,
                              height: 7.vh,
                            ),
                            Spacer(),
                            ElevatedButton.icon(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.focused)) {
                                    return theme.primaryColorDark;
                                  }
                                  return Colors.white;
                                }),
                                elevation: MaterialStateProperty.all(0),
                                overlayColor: MaterialStateProperty.all(Colors.transparent),
                                foregroundColor: MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.focused)) {
                                    return Colors.white;
                                  }
                                  return theme.primaryColor;
                                }),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 10, vertical: 0)),
                              ),
                              onPressed: () => SystemNavigator.pop(),
                              icon: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 15,
                                  color: theme.primaryColor,
                                ),
                              ),
                              label: Text(S.of(context).quit),
                            ),
                            // ActionChip(
                            //   // backgroundColor: theme.brightness == Brightness.dark ? Colors.white : theme.primaryColor,
                            //   // labelStyle: TextStyle(
                            //   //   color: theme.brightness == Brightness.dark ? theme.primaryColor : Colors.white,
                            //   // ),
                            //   onPressed: () {},
                            //   label: Text("Quit"),
                            //   padding: EdgeInsets.all(0),
                            //   avatar: Container(
                            //     padding: EdgeInsets.all(3),
                            //     decoration: BoxDecoration(
                            //       color: Colors.black26,
                            //       shape: BoxShape.circle,
                            //     ),
                            //     child: Icon(
                            //       Icons.close,
                            //       color: theme.primaryColor,
                            //       size: 15,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            // settings.title!,
                            S.of(context).drawerTitle,
                            overflow: TextOverflow.ellipsis,
                            // style: TextStyle( fontSize: 16),
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Text(
                              // settings.subTitle!,
                              S.of(context).drawerDesc,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14)),
                        ),
                        SizedBox(height: 7),
                        VersionWidget(style: theme.textTheme.labelSmall),
                      ],
                    ),
                  )),
              Divider(),
              DrawerListTitle(
                  autoFocus: true,
                  icon: Icons.home,
                  text: S.of(context).home,
                  onTap: () async {
                    Navigator.pop(context);

                    goHome();
                  }),
              DrawerListTitle(
                icon: Icons.book,
                text: S.of(context).quran,
                onTap: () async {
                  await ref.read(quranNotifierProvider.notifier).getSelectedMode();
                  final state = ref.read(quranNotifierProvider);
                  Navigator.pop(context);

                  switch (state.value!.mode) {
                    case QuranMode.reading:
                      log('quran: MawaqitDrawer: build: quranNotifierProvider: mode: reading');
                      Navigator.pushNamed(context, Routes.quranReading);
                      break;
                    case QuranMode.listening:
                      log('quran: MawaqitDrawer: build: quranNotifierProvider: mode: listening');
                      Navigator.pushNamed(context, Routes.quranReciter);
                      break;
                    case QuranMode.none:
                      Navigator.pushNamed(context, Routes.quranModeSelection);
                      break;
                  }
                },
              ),
              DrawerListTitle(
                icon: Icons.settings,
                text: S.of(context).settings,
                onTap: () => AppRouter.popAndPush(SettingScreen()),
              ),
              if (userPrefs.developerModeEnabled) DrawerListDeveloper(),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: Divider(height: 1, color: Colors.grey[400]),
              ),
              DrawerListTitle(
                icon: Icons.info,
                text: S.of(context).about,
                onTap: () => AppRouter.popAndPush(AboutScreen()),
              ),
              DrawerListTitle(
                  icon: Icons.share,
                  text: S.of(context).share,
                  onTap: () {
                    _shareApp(context, MawaqitBackendSettingsConstant.kSettingsTitle,
                        MawaqitBackendSettingsConstant.kSettingsShare);
                  }),
              DrawerListTitle(
                icon: Icons.star,
                text: S.of(context).rate,
                onTap: () => OpenStore.instance.open(
                  androidAppBundleId: kAppId,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  _shareApp(BuildContext context, String? text, String share) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    Share.share(share, subject: text, sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }
}
