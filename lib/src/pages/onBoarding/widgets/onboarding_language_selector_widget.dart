import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/LocaleHelper.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    Key? key,
    required this.onSelect,
    required this.isSelected,
    required this.languages,
    this.title = "",
    this.description = "",
    this.isIconActivated = true,
  }) : super(key: key);

  /// Called when user selects a language
  final void Function(String) onSelect;

  /// List of language codes
  final List<String> languages;

  /// Controls whether to show language icons
  final bool isIconActivated;

  /// Title displayed at the top of the screen
  final String title;

  /// Description of the screen purpose
  final String description;

  /// Function to determine if a language is selected
  final bool Function(String) isSelected;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Column(
      children: [
        SizedBox(height: 1.h),

        // Title section
        _buildTitleSection(context, themeData),
        SizedBox(height: 1.5.h),

        // Language list section
        _buildLanguageListSection(context),
      ],
    );
  }

  /// Builds the title and description section
  Widget _buildTitleSection(BuildContext context, ThemeData themeData) {
    return Column(
      children: [
        Text(
          title.isEmpty ? S.of(context).appLang : title,
          style: TextStyle(
            fontSize: 16.sp, // Responsive font size
            fontWeight: FontWeight.w700,
            color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
          ),
        ).animate().slideY().fade(),
        SizedBox(height: 0.5.h),
        Text(
          description.isEmpty ? S.of(context).descLang : description,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 10.sp, // Responsive font size
            color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
          ),
        ).animate().slideX(begin: .5).fade(),
      ],
    );
  }

  /// Builds the scrollable language list
  Widget _buildLanguageListSection(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(top: 1.h),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(
            vertical: 0.5.h,
            horizontal: 2.w,
          ),
          itemCount: languages.length,
          itemBuilder: (BuildContext context, int index) {
            final Locale locale = LocaleHelper.splitLocaleCode(languages[index]);
            return LanguageTile(
              onTap: () => onSelect(LocaleHelper.transformLocaleToString(locale)),
              locale: locale,
              isSelected: isSelected(LocaleHelper.transformLocaleToString(locale)),
              isIconActivated: isIconActivated,
            );
          },
        ),
      ),
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
        padding: EdgeInsets.symmetric(
          horizontal: 1.w,
          vertical: 0.5.h,
        ),
        child: Ink(
          decoration: BoxDecoration(
            color: widget.isSelected ? themeData.focusColor : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              widget.onTap();
              setState(() {});
            },
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 0.5.h,
              ),
              textColor: widget.isSelected ? Colors.white : null,
              leading: widget.isIconActivated
                  ? flagIcon(LocaleHelper.transformLocaleToString(widget.locale), size: 10.w)
                  : null,
              title: Text(
                appLanguage.combinedLanguageName(LocaleHelper.transformLocaleToString(widget.locale)),
                style: TextStyle(
                  fontSize: 13.sp, // Responsive font size
                  fontWeight: FontWeight.normal,
                ),
              ),
              trailing: widget.isSelected
                  ? Icon(
                      MawaqitIcons.icon_checked,
                      color: Colors.white,
                      size: 5.w, // Responsive icon size
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget flagIcon(String languageCode, {double? size}) {
    final s = size ?? 16.0.sp;
    return SizedBox(
      width: s,
      height: s,
      child: CircleAvatar(
        foregroundImage: AssetImage(
          'assets/img/flag/$languageCode.png',
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}
