import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

class OnBoardingLanguageSelector extends StatelessWidget {
  const OnBoardingLanguageSelector({Key? key, required this.onSelect}) : super(key: key);

  final void Function() onSelect;

  @override
  Widget build(BuildContext context) {
    final locales = S.delegate.supportedLocales;
    final appLanguage = Provider.of<AppLanguage>(context);
    final themeData = Theme.of(context);

    /// if the [langCode] is current used language
    bool isSelected(String langCode) => appLanguage.appLocal.languageCode == langCode;

    final sortedLocales = [
      locales.first,
      ...locales.sublist(1)
        ..sort(
          (a, b) => appLanguage.languageName(a.languageCode).compareTo(appLanguage.languageName(b.languageCode)),
        ),
    ];

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
        ),
        SizedBox(height: 8),
        Text(
          S.of(context).descLang,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(top: 5),
            child: ListView.separated(
              padding: EdgeInsets.only(
                top: 5,
                bottom: 5,
              ),
              itemCount: sortedLocales.length,
              separatorBuilder: (BuildContext context, int index) => Divider(height: 1),
              itemBuilder: (BuildContext context, int index) {
                var locale = sortedLocales[index];
                return LanguageTile(
                  onSelect: onSelect,
                  locale: locale,
                  isSelected: isSelected(locale.languageCode),
                );
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
            color: isFocused || widget.isSelected ? themeData.selectedRowColor : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            autofocus: widget.isSelected,
            onFocusChange: (i) => setState(() => isFocused = i),
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              appLanguage.changeLanguage(widget.locale, mosqueManager.mosqueId);
              widget.onSelect();
            },
            child: ListTile(
              dense: true,
              textColor: isFocused || widget.isSelected ? Colors.white : null,
              leading: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset('assets/img/flag/${widget.locale.languageCode}.png'),
              ),
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
}
