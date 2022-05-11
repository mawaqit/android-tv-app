import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:launch_review/launch_review.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/elements/DrawerListTitle.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/HexColor.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/models/menu.dart';
import 'package:mawaqit/src/models/page.dart';
import 'package:mawaqit/src/models/settings.dart';
import 'package:mawaqit/src/pages/AboutScreen.dart';
import 'package:mawaqit/src/pages/LanguageScreen.dart';
import 'package:mawaqit/src/pages/MosqueSearchScreen.dart';
import 'package:mawaqit/src/pages/PageScreen.dart';
import 'package:mawaqit/src/pages/WebScreen.dart';
import 'package:mawaqit/src/services/settings_manager.dart';
import 'package:mawaqit/src/services/theme_manager.dart';
import 'package:mawaqit/src/widgets/InfoWidget.dart';
import 'package:mawaqit/src/widgets/MawaqitWebViewWidget.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class MawaqitDrawer extends StatelessWidget {
  const MawaqitDrawer({Key? key, required this.webViewKey}) : super(key: key);

  final GlobalKey<MawaqitWebViewWidgetState> webViewKey;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsManager>(context).settings;
    final themeProvider = Provider.of<ThemeNotifier>(context);

    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0.0),
        children: <Widget>[
          Focus(child: SizedBox()),
          DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Theme.of(context).brightness == Brightness.light
                        ? HexColor(settings.firstColor)
                        : Theme.of(context).primaryColor,
                    Theme.of(context).brightness == Brightness.light
                        ? HexColor(settings.secondColor)
                        : Theme.of(context).primaryColor,
                  ],
                ),
              ),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 70.0,
                      height: 70.0,
                      child: Image.network(
                        settings.logoHeaderUrl!,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                          // settings.title!,
                          S.of(context).drawerTitle,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                          // settings.subTitle!,
                          S.of(context).drawerDesc,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                    )
                  ],
                ),
              )),
          DrawerListTitle(
              autoFocus: true,
              icon: Icons.home,
              text: S.of(context).home,
              onTap: () async {
                if (settings.tabNavigationEnable == "1") {
                  AppRouter.popAndPush(WebScreen(settings.url), name: 'HomeScreen');
                } else {
                  webViewKey.currentState?.goHome();

                  Navigator.pop(context);
                }
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
              text: Theme.of(context).brightness == Brightness.light ? S.of(context).darkMode : S.of(context).lightMode,
              onTap: () {
                if (Theme.of(context).brightness == Brightness.light) {
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
          Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: Divider(height: 1, color: Colors.grey[400]),
          ),
          ListTile(
            leading: Icon(Icons.system_update),
            isThreeLine: true,
            dense: true,
            title: Text(S.of(context).update),
            subtitle: VersionWidget(),
          ),
          Focus(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _renderMenuDrawer(Settings settings, BuildContext context) {
    List<Menu> menus = settings.menus ?? [];

    return new Column(
      children: menus
          .map(
            (Menu menu) => DrawerListTitle(
                iconUrl: menu.iconUrl,
                text: menu.title,
                onTap: () async {
                  if (settings.tabNavigationEnable == "1") {
                    AppRouter.push(WebScreen(menu.url), name: menu.title);
                  } else {
                    webViewKey.currentState!.webViewController
                        ?.loadUrl(urlRequest: URLRequest(url: Uri.parse(menu.url!)));

                    Navigator.pop(context);
                  }
                }),
          )
          .toList(),
    );
  }

  Widget _renderPageDrawer(List<Page> pages, context) {
    return new Column(
      children: pages
          .map(
            (Page page) => DrawerListTitle(
              forceThemeColor: true,
              iconUrl: page.iconUrl,
              text: Intl.message(page.title ?? '', name: page.title?.toCamelCase),
              onTap: () => AppRouter.popAndPush(PageScreen(page), name: page.title),
            ),
          )
          .toList(),
    );
  }

  _shareApp(BuildContext context, String? text, String share) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    Share.share(share, subject: text, sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }
}
