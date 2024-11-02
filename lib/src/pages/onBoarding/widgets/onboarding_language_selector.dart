import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

class OnBoardingLanguageSelector extends StatefulWidget {
  const OnBoardingLanguageSelector({Key? key, required this.onSelect}) : super(key: key);

  final void Function() onSelect;

  @override
  State<OnBoardingLanguageSelector> createState() => _OnBoardingLanguageSelectorState();
}

class _OnBoardingLanguageSelectorState extends State<OnBoardingLanguageSelector> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locales = S.supportedLocales;
    final appLanguage = Provider.of<AppLanguage>(context);
    final themeData = Theme.of(context);

    /// if the [langCode] is current used language
    bool isSelected(String langCode) => appLanguage.appLocal.languageCode == langCode;

    final sortedLocales = [
      Locale('ar'),
      ...locales.where((element) => element.languageCode != 'ar' && element.languageCode != 'ba').toList()
        ..sort((a, b) => appLanguage
            .languageName(a.languageCode)
            .toLowerCase()
            .compareTo(appLanguage.languageName(b.languageCode).toLowerCase())),
    ];

    // After defining your sortedLocales and other UI components
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final appLanguage = Provider.of<AppLanguage>(context, listen: false);
        int selectedIndex =
            sortedLocales.indexWhere((locale) => appLanguage.appLocal.languageCode == locale.languageCode);
        if (selectedIndex != -1) {
          double position = selectedIndex * 51; // Estimate the height per item. Adjust this based on your item height.
          _scrollController.animateTo(
            position,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });

    return Column(
      children: [
        SizedBox(height: 10),
        Text(
          S.of(context).appLang,
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.w700,
            color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
          ),
        ).animate().slideY().fade(),
        SizedBox(height: 8),
        Text(
          S.of(context).descLang,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
          ),
        ).animate().slideX(begin: .5).fade(),
        SizedBox(height: 20),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(top: 5),
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.only(
                top: 5,
                bottom: 5,
              ),
              itemCount: sortedLocales.length,
              separatorBuilder: (BuildContext context, int index) =>
                  Divider(height: 1).animate().fade(delay: .7.seconds),
              itemBuilder: (BuildContext context, int index) {
                var locale = sortedLocales[index];
                print('locale: ${locale.languageCode}');
                return LanguageTile(
                  onSelect: widget.onSelect,
                  locale: locale,
                  isSelected: isSelected(locale.languageCode),
                );
                // .animate(delay: 110.milliseconds * index)
                // .moveX(begin: 200)
                // .fade();
              },
            ),
          ),
        )
      ],
    );
  }
}

class LanguageTile extends StatefulWidget {
  const LanguageTile({
    Key? key,
    required this.isSelected,
    required this.locale,
    required this.onSelect,
  }) : super(key: key);

  final bool isSelected;
  final Locale locale;

  final void Function() onSelect;

  @override
  State<LanguageTile> createState() => _LanguageTileState();
}

class _LanguageTileState extends State<LanguageTile> {
  late bool isFocused = widget.isSelected;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final appLanguage = Provider.of<AppLanguage>(context);
    final mosqueManager = Provider.of<MosqueManager>(context);

    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
        child: Ink(
          decoration: BoxDecoration(
            color: isFocused
                ? themeData.selectedRowColor
                : widget.isSelected
                    ? themeData.selectedRowColor.withGreen(140)
                    : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            autofocus: widget.isSelected,
            onFocusChange: (i) => setState(() => isFocused = i),
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              appLanguage.changeLanguage(widget.locale, mosqueManager.mosqueUUID);
              widget.onSelect();
            },
            child: ListTile(
              dense: true,
              textColor: isFocused || widget.isSelected ? Colors.white : null,
              leading: flagIcon(widget.locale.languageCode),
              title: Text(
                appLanguage.languageName(widget.locale.languageCode),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              trailing: widget.isSelected ? Icon(MawaqitIcons.icon_checked, color: Colors.white) : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget flagIcon(String languageCode, {double size = 40}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(300),
        // color: Colors.white,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/img/flag/${widget.locale.languageCode}.png',
        fit: BoxFit.fill,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) {
          FirebaseCrashlytics.instance.recordError(error, stackTrace);
          return SizedBox();
        },
      ),
    );
  }
}
