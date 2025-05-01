import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart' as provider;
import 'package:sizer/sizer.dart'; // Prefix the provider import

class OnBoardingLanguageSelector extends ConsumerStatefulWidget {
  final bool isOnboarding;
  final VoidCallback? onSelect; // Renamed for consistency
  final FocusNode? nextButtonFocusNode;

  // Private constructor
  const OnBoardingLanguageSelector._({
    Key? key,
    required this.isOnboarding,
    this.nextButtonFocusNode,
    this.onSelect,
  }) : super(key: key);

  // Factory constructor
  factory OnBoardingLanguageSelector({
    Key? key,
    bool isOnboarding = true,
    VoidCallback? onNext,
    FocusNode? nextButtonFocusNode,
  }) {
    return OnBoardingLanguageSelector._(
      key: key,
      isOnboarding: isOnboarding,
      nextButtonFocusNode: nextButtonFocusNode,
      onSelect: onNext, // Assigning to onSelect
    );
  }

  // Named factory constructor for normal mode
  factory OnBoardingLanguageSelector.normal({
    Key? key,
    required VoidCallback onNext,
    FocusNode? nextButtonFocusNode,
  }) {
    return OnBoardingLanguageSelector._(
      key: key,
      isOnboarding: false,
      nextButtonFocusNode: nextButtonFocusNode,
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
  ConsumerState<OnBoardingLanguageSelector> createState() => _OnBoardingLanguageSelectorState();
}

class _OnBoardingLanguageSelectorState extends ConsumerState<OnBoardingLanguageSelector> {
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
          double position = selectedIndex * (6.h); // Adjusted based on item height with sizer
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
        SizedBox(height: 2.h),
        Text(
          S.of(context).appLang,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
              ),
        ).animate().slideY().fade(),
        SizedBox(height: 1.5.h),
        Text(
          S.of(context).descLang,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: 14.sp,
                color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
              ),
        ).animate().slideX(begin: .5).fade(),
        SizedBox(height: 3.h),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(top: 0.5.h),
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(vertical: 0.5.h),
              itemCount: sortedLocales.length,
              separatorBuilder: (BuildContext context, int index) =>
                  Divider(height: 0.1.h).animate().fade(delay: .7.seconds),
              itemBuilder: (BuildContext context, int index) {
                var locale = sortedLocales[index];
                return LanguageTile(
                  onSelect: widget.onSelect ??
                      () {
                        if (widget.nextButtonFocusNode != null) {
                          widget.nextButtonFocusNode?.requestFocus();
                        }
                      }, // Pass the onSelect callback
                  locale: locale,
                  isSelected: isSelected(locale.languageCode),
                );
              },
            ),
          ),
        ),
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
        padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.2.h),
        child: Ink(
          decoration: BoxDecoration(
            color: isFocused
                ? Theme.of(context).focusColor
                : widget.isSelected
                    ? Theme.of(context).focusColor
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
                contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                textColor: isFocused || widget.isSelected ? Colors.white : null,
                leading: flagIcon(widget.locale.languageCode),
                title: Text(
                  appLanguage.languageName(widget.locale.languageCode),
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600),
                ),
                trailing: widget.isSelected ? Icon(MawaqitIcons.icon_checked, color: Colors.white, size: 14.sp) : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget flagIcon(String languageCode, {double? size}) {
    final flagSize = size ?? 6.w; // Responsive size if not provided
    return Container(
      width: flagSize,
      height: flagSize,
      // Add height equal to width for a perfect circle
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(flagSize / 2), // Use half of size for perfect circle
        // color: Colors.white,
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipOval(
        child: Image.asset(
          'assets/img/flag/${widget.locale.languageCode}.png',
          fit: BoxFit.cover,
          width: flagSize,
          errorBuilder: (context, error, stackTrace) {
            FirebaseCrashlytics.instance.recordError(error, stackTrace);
            return SizedBox();
          },
        ),
      ),
    );
  }
}
