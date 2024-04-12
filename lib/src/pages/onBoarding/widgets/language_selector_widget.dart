import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:provider/provider.dart';

class LanguageSelector extends StatelessWidget {
  LanguageSelector({
    Key? key,
    required this.onSelect,
    required this.isSelected,
    required this.languages, // List of languages
    this.title = "",
    this.description = "", // Description of the screen
    this.isIconActivated = true,
  }) : super(key: key);

  /// [onSelect] is called when user select a language
  final void Function(String) onSelect;

  /// [languages] is a list of language codes
  final List<String> languages;
  final bool isIconActivated;

  /// [title] is the title of the screen placed at the top of the screen
  final String title;

  /// [description] is the description of the screen
  final String description;

  /// [isSelected] is a function that return true if the language is selected
  final bool Function(String) isSelected;
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Column(
      children: [
        SizedBox(height: 10),
        Text(
          title.isEmpty ? S.of(context).appLang : title,
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
              padding: EdgeInsets.only(
                top: 5,
                bottom: 5,
              ),
              itemCount: languages.length,
              separatorBuilder: (BuildContext context, int index) =>
                  Divider(height: 1).animate().fade(delay: .7.seconds),
              itemBuilder: (BuildContext context, int index) {
                final Locale locale = Locale(languages[index]);
                return LanguageTile(
                  onTap: () => onSelect(locale.languageCode),
                  locale: locale,
                  isSelected: isSelected(locale.languageCode),
                  isIconActivated: isIconActivated,
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
    required this.locale,
    required this.onTap,
    this.isIconActivated = true,
    this.isSelected = false,
  }) : super(key: key);

  final bool isIconActivated;
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<LanguageTile> createState() => _LanguageTileState();
}

class _LanguageTileState extends State<LanguageTile> {
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final appLanguage = Provider.of<AppLanguage>(context);
    return Material(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
      child: Ink(
        decoration: BoxDecoration(
          color: widget.isSelected ? themeData.selectedRowColor : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          // autofocus: widget.isSelected,
          // onFocusChange: (i) => setState(() => isFocused = i),
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            widget.onTap();
            setState(() {});
          },
          child: ListTile(
            dense: true,
            textColor: widget.isSelected ? Colors.white : null,
            leading: widget.isIconActivated ? flagIcon(widget.locale.languageCode) : null,
            title: Text(
              appLanguage.combinedLanguageName(widget.locale.languageCode),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            trailing: widget.isSelected ? Icon(MawaqitIcons.icon_checked, color: Colors.white) : null,
          ),
        ),
      ),
    ));
  }

  Widget flagIcon(String languageCode, {double size = 40}) {
    List<String> codes = languageCode.split('_');
    if (codes.length == 2) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSingleFlag(codes[0], size: size), // First language flag
          SizedBox(width: 10), // Space between flags
          _buildSingleFlag(codes[1], size: size), // Second language flag
        ],
      );
    } else {
      return _buildSingleFlag(languageCode, size: size);
    }
  }
}

Widget _buildSingleFlag(String code, {double size = 40}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(300),
    ),
    clipBehavior: Clip.antiAlias,
    child: Image.asset(
      'assets/img/flag/$code.png',
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
