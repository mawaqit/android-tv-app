import 'dart:io';

import 'package:flutter/material.dart' hide Page;
import 'package:intl/intl.dart' hide TextDirection;
import 'package:launch_review/launch_review.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/elements/DrawerListTitle.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/models/menu.dart';
import 'package:mawaqit/src/models/page.dart';
import 'package:mawaqit/src/models/settings.dart';
import 'package:mawaqit/src/pages/AboutScreen.dart';
import 'package:mawaqit/src/pages/LanguageScreen.dart';
import 'package:mawaqit/src/pages/MosqueSearchScreen.dart';
import 'package:mawaqit/src/pages/PageScreen.dart';
import 'package:mawaqit/src/pages/WebScreen.dart';
import 'package:mawaqit/src/pages/home/OfflineHomeScreen.dart';
import 'package:mawaqit/src/services/settings_manager.dart';
import 'package:mawaqit/src/services/theme_manager.dart';
import 'package:mawaqit/src/widgets/InfoWidget.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class MawaqitDrawer extends StatelessWidget {
  const MawaqitDrawer({Key? key, required this.goHome}) : super(key: key);

  // final GlobalKey<MawaqitWebViewWidgetState> webViewKey;
  final VoidCallback goHome;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsManager>(context).settings;
    final themeProvider = Provider.of<ThemeNotifier>(context);
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
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              height: 70.0,
                              // child: Image.network(settings.logoHeaderUrl!),
                              child: Image.asset('assets/img/logo/logo-mawaqit-2022-horizontal.png'),
                            ),
                          ),
                        ),
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
                            //     foregroundColor: MaterialStateProperty.resolveWith((states) {
                            //   if (states.contains(MaterialState.focused)) {
                            //     return Colors.white;
                            //   }
                            // })
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
                  goHome();

                  Navigator.pop(context);
                }
              }),
          DrawerListTitle(
              icon: Icons.home_filled,
              text: "Offline home",
              onTap: () async {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => OfflineHomeScreen()));
              }),
          _renderMenuDrawer(settings, context),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: Divider(height: 1, color: Colors.grey[400]),
          ),
          DrawerListTitle(
            icon: Icons.translate,
            text: S.of(context).languages,
            onTap: () => AppRouter.popAndPush(LanguageScreen()),
          ),
          DrawerListTitle(
            icon: Icons.museum_outlined,
            text: S.of(context).changeMosque,
            onTap: () => AppRouter.popAndPush(MosqueSearchScreen()),
          ),
          DrawerListTitle(
              icon: Icons.brightness_medium,
              text: theme.brightness == Brightness.light ? S.of(context).darkMode : S.of(context).lightMode,
              onTap: () {
                if (theme.brightness == Brightness.light) {
                  themeProvider.setDarkMode();
                } else {
                  themeProvider.setLightMode();
                }
              }),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: Divider(height: 1, color: Colors.grey[400]),
          ),
          _renderPageDrawer(settings.pages!, context),
          settings.pages!.length != 0
              ? Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Divider(height: 1, color: Colors.grey[400]),
                )
              : Container(height: 0),
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
    return new Column(
      children: pages
          .map((Page page) => DrawerListTitle(
                forceThemeColor: true,
                iconUrl: page.iconUrl,
                text: Intl.message(page.title ?? '', name: page.title?.toCamelCase),
                onTap: () => AppRouter.popAndPush(PageScreen(page), name: page.title),
              ))
          .toList(),
    );
  }

  _shareApp(BuildContext context, String? text, String share) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    Share.share(share, subject: text, sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }
}
