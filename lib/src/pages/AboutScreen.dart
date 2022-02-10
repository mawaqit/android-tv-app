import 'package:flutter/material.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/elements/SocialItem.dart';
import 'package:flyweb/src/helpers/AppConfig.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/models/social.dart';
import 'package:flyweb/src/services/settings_manager.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _AboutScreen();
}

class _AboutScreen extends State<AboutScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final settingsManager = Provider.of<SettingsManager>(context);

    return Scaffold(
      appBar: _renderAppBar(context, settingsManager.settings),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/img/background.png'),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    FractionallySizedBox(
                      widthFactor: .25,
                      child: Image.asset(
                        'assets/img/mawaqit_logo_light_with_text_horizontal_Background.png',
                      ),
                    ),
                    const SizedBox(height: 7),
                    Center(
                      child: Text(
                        settingsManager.settings.title?.toUpperCase() ?? '',
                        style: GoogleFonts.montserrat(
                          color: AppColors().mainColor(),
                          letterSpacing: 4,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          fontSize: 30,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) => Text(
                        "V " + (snapshot.data?.version ?? ''),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FractionallySizedBox(
                      widthFactor: .75,
                      child: Material(
                        color: AppColors().mainColor(.3),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 40,
                          ),
                          child: Text(
                            settingsManager.settings.aboutUs ?? '',
                            style: GoogleFonts.montserrat(
                              color: Colors.white54,
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                              height: 48 / 33,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _renderSocialList(settingsManager.settings.socials!, context),
            const SizedBox(height: 30),
          ],
        ),
      ),
      // Column(
      //   children: <Widget>[
      //     Padding(
      //       padding: EdgeInsets.only(left: 0, top: 80, right: 0, bottom: 10),
      //       child: Container(
      //         width: 100.0,
      //         height: 100.0,
      //         decoration: BoxDecoration(
      //           //color: Colors.white,
      //           borderRadius: BorderRadius.only(
      //               topLeft: Radius.circular(100),
      //               topRight: Radius.circular(100),
      //               bottomLeft: Radius.circular(100),
      //               bottomRight: Radius.circular(100)),
      //           boxShadow: [
      //             BoxShadow(
      //               color: Colors.grey.withOpacity(0.5),
      //               spreadRadius: 5,
      //               blurRadius: 3,
      //               offset: Offset(0, 3), // changes position of shadow
      //             ),
      //           ],
      //         ),
      //         child: Padding(
      //             padding: EdgeInsets.all(13),
      //             child: Image.network(
      //               widget.settings.logoHeaderUrl!,
      //             )),
      //       ),
      //     ),
      //     Padding(
      //       padding: EdgeInsets.only(left: 0, top: 10, right: 0, bottom: 10),
      //       child: Center(
      //           child: Text(
      //         widget.settings.title!,
      //         textAlign: TextAlign.center,
      //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      //       )),
      //     ),
      //     FutureBuilder<PackageInfo>(
      //       future: PackageInfo.fromPlatform(),
      //       builder: (context, snapshot) => Text(
      //         "v " + (snapshot.data?.version ?? ''),
      //         textAlign: TextAlign.center,
      //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
      //       ),
      //     ),
      //     Padding(
      //       padding: EdgeInsets.only(left: 20, top: 40, right: 20, bottom: 10),
      //       child: Center(
      //           child: Text(
      //         widget.settings.aboutUs!,
      //         textAlign: TextAlign.center,
      //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
      //       )),
      //     ),
      //     Spacer(flex: 1),
      //     Padding(
      //       padding: EdgeInsets.only(bottom: 20),
      //       child: Text(
      //         "Follow Us",
      //         textAlign: TextAlign.center,
      //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
      //       ),
      //     ),
      //     _renderSocialList(widget.settings.socials!, context),
      //     SizedBox(height: 30),
      //   ],
      // ),
    );
  }
}

AppBar _renderAppBar(context, Settings settings) {
  var themeProvider = Provider.of<ThemeNotifier>(context);
  return AppBar(
    title: Text(
      I18n.current!.about,
      style: TextStyle(
          color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold),
    ),
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            themeProvider.isLightTheme!
                ? HexColor(settings.firstColor)
                : themeProvider.darkTheme.primaryColor,
            themeProvider.isLightTheme!
                ? HexColor(settings.secondColor)
                : themeProvider.darkTheme.primaryColor,
          ],
        ),
      ),
    ),
  );
}

Widget _renderSocialList(List<Social> socials, context) {
  return new Wrap(
    spacing: 18.0,
    runSpacing: 20,
    children: socials
        .map((Social social) => SocialItem(
              iconUrl: social.iconUrl,
              text: I18n.current!.social(social.title),
              onTap: () async {
                if (await canLaunch(
                    social.linkUrl!.replaceAll("id_app", social.idApp!))) {
                  await launch(
                      social.linkUrl!.replaceAll("id_app", social.idApp!));
                } else {
                  launch(social.url!.replaceAll("id_app", social.idApp!));
                }
              },
            ))
        .toList(),
  );
}
