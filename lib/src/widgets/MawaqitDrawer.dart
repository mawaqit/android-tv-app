import 'dart:io';

import 'package:flutter/material.dart' hide Page;
import 'package:flutter_svg/svg.dart';
import 'package:launch_review/launch_review.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/elements/DrawerListTitle.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/models/menu.dart';
import 'package:mawaqit/src/models/page.dart';
import 'package:mawaqit/src/models/settings.dart';
import 'package:mawaqit/src/pages/AboutScreen.dart';
import 'package:mawaqit/src/pages/LanguageScreen.dart';
import 'package:mawaqit/src/pages/MosqueSearchScreen.dart';
import 'package:mawaqit/src/pages/PageScreen.dart';
import 'package:mawaqit/src/pages/WebScreen.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/settings_manager.dart';
import 'package:mawaqit/src/services/theme_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/src/widgets/InfoWidget.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../developer_mode/DrawerListTest.dart';
import '../pages/SettingScreen.dart';

class MawaqitDrawer extends StatelessWidget {
  const MawaqitDrawer({Key? key, required this.goHome}) : super(key: key);

  final VoidCallback goHome;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsManager>(context).settings;
    final mosqueManager = context.watch<MosqueManager>();
    final userPrefs = context.watch<UserPreferencesManager>();

    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
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
                          onPressed: () => exit(0),
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
                if (settings.tabNavigationEnable == "1") {
                  AppRouter.popAndPush(WebScreen(settings.url), name: 'HomeScreen');
                } else {
                  Navigator.pop(context);

                  goHome();
                }
              }),
          _renderMenuDrawer(settings, context),
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
                _shareApp(context, settings.title, settings.share!);
              }),
          DrawerListTitle(
            icon: Icons.star,
            text: S.of(context).rate,
            onTap: () => LaunchReview.launch(
              androidAppId: settings.androidId,
              iOSAppId: settings.iosId,
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _renderMenuDrawer(Settings settings, BuildContext context) {
    List<Menu> menus = settings.menus ?? [];

    return new Column(
      children: menus
          .map((Menu menu) => DrawerListTitle(
              iconUrl: menu.iconUrl,
              forceThemeColor: true,
              autoTranslate: true,
              text: menu.title,
              onTap: () async {
                AppRouter.push(WebScreen(menu.url), name: menu.title);
                Navigator.pop(context);
              }))
          .toList(),
    );
  }

  Widget _renderPageDrawer(List<Page> pages, context) {
    final translations = {
      "privacyPolicy": S.of(context).privacyPolicy,
      "networkStatus": S.of(context).networkStatus,
      "termsOfService": S.of(context).termsOfService,
      "installationGuide": S.of(context).installationGuide,
    };

    return Column(
      children: pages
          .map((Page page) => DrawerListTitle(
              forceThemeColor: true,
              iconUrl: page.iconUrl,
              text: translations[page.title!.toCamelCase] ?? page.title,
              onTap: () => AppRouter.popAndPush(PageScreen(page), name: page.title)))
          .toList(),
    );
  }

  _shareApp(BuildContext context, String? text, String share) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    Share.share(share, subject: text, sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }
}
