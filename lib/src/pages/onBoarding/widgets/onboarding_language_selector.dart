import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/pages/onBoarding/OnBoardingScreen.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart' as provider; // Prefix the provider import

class OnBoardingLanguageSelector extends StatefulWidget {
  final bool isOnboarding;
  final VoidCallback? onSelect; // Renamed for consistency

  // Private constructor
  const OnBoardingLanguageSelector._({
    Key? key,
    required this.isOnboarding,
    this.onSelect,
  }) : super(key: key);

  // Factory constructor
  factory OnBoardingLanguageSelector({
    Key? key,
    bool isOnboarding = true,
    VoidCallback? onNext,
  }) {
    return OnBoardingLanguageSelector._(
      key: key,
      isOnboarding: isOnboarding,
      onSelect: onNext, // Assigning to onSelect
    );
  }

  // Named factory constructor for normal mode
  factory OnBoardingLanguageSelector.normal({Key? key, required VoidCallback onNext}) {
    return OnBoardingLanguageSelector._(
      key: key,
      isOnboarding: false,
      onSelect: onNext,
    );
  }

  // Named factory constructor for onboarding mode
  factory OnBoardingLanguageSelector.onboarding({
    Key? key,
  }) {
    return OnBoardingLanguageSelector._(
      key: key,
      isOnboarding: true,
    );
  }

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
    final appLanguage = provider.Provider.of<AppLanguage>(context); // Use prefixed Provider
    final themeData = Theme.of(context);

    /// Check if the [langCode] is the currently used language
    bool isSelected(String langCode) => appLanguage.appLocal.languageCode == langCode;

    final sortedLocales = [
      Locale('ar'),
      ...locales.where((element) => element.languageCode != 'ar' && element.languageCode != 'ba').toList()
        ..sort((a, b) => appLanguage
            .languageName(a.languageCode)
            .toLowerCase()
            .compareTo(appLanguage.languageName(b.languageCode).toLowerCase())),
    ];

    // Scroll to the selected language after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final appLanguage = provider.Provider.of<AppLanguage>(context, listen: false); // Use prefixed Provider
        int selectedIndex =
            sortedLocales.indexWhere((locale) => appLanguage.appLocal.languageCode == locale.languageCode);
        if (selectedIndex != -1) {
          double position = selectedIndex * 51; // Adjust based on item height
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
                return LanguageTile(
                  onSelect: widget.onSelect ?? () {}, // Pass the onSelect callback
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

class LanguageTile extends ConsumerStatefulWidget {
  const LanguageTile({
    Key? key,
    required this.isSelected,
    required this.locale,
    required this.onSelect,
  }) : super(key: key);

  final bool isSelected;
  final Locale locale;
  final VoidCallback onSelect;

  @override
  ConsumerState<LanguageTile> createState() => _LanguageTileState();
}

class _LanguageTileState extends ConsumerState<LanguageTile> {
  late bool isFocused = widget.isSelected;
  final focusNode = FocusNode();

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final appLanguage = provider.Provider.of<AppLanguage>(context); // Use prefixed Provider
    final mosqueManager = provider.Provider.of<MosqueManager>(context); // Use prefixed Provider

    void handleSelection() {
      appLanguage.changeLanguage(widget.locale, mosqueManager.mosqueUUID);
      widget.onSelect(); // Invoke the callback to navigate
    }

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
          child: Focus(
            focusNode: focusNode,
            autofocus: widget.isSelected,
            onFocusChange: (hasFocus) => setState(() => isFocused = hasFocus),
            onKey: (node, event) {
              if (event is RawKeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
                  ref.read(nextNodeProvider).requestFocus();
                  handleSelection();
                  return KeyEventResult.handled;
                }

                if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                  node.nextFocus();
                  return KeyEventResult.handled;
                }

                if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                  node.previousFocus();
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
            child: InkWell(
              onTap: handleSelection,
              borderRadius: BorderRadius.circular(10),
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
