import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/LocaleHelper.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart' as provider;
import 'package:sizer/sizer.dart'; // Prefix the provider import
import 'package:scroll_to_index/scroll_to_index.dart';

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
  late AutoScrollController _scrollController;
  int _focusedIndex = 0;
  List<FocusNode> _focusNodes = [];
  List<Locale> _sortedLocales = [];

  @override
  void initState() {
    super.initState();
    _scrollController = AutoScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _scrollToIndex(int index) {
    if (_scrollController.hasClients) {
      _scrollController.scrollToIndex(
        index,
        duration: Duration(milliseconds: 200),
      );
    }
  }

  void _changeFocus(int newIndex) {
    if (newIndex < 0 || newIndex >= _focusNodes.length) {
      return; // Don't go outside bounds
    }

    setState(() {
      _focusedIndex = newIndex;
      _focusNodes[newIndex].requestFocus();
    });

    _scrollToIndex(newIndex);
  }

  @override
  Widget build(BuildContext context) {
    final locales = S.supportedLocales;
    final appLanguage = provider.Provider.of<AppLanguage>(context); // Use prefixed Provider
    final themeData = Theme.of(context);

    /// Check if the [langCode] is the currently used language
    bool isSelected(String langCode) => LocaleHelper.transformLocaleToString(appLanguage.appLocal) == langCode;

    _sortedLocales = [
      Locale('ar'),
      ...locales
          .where((element) =>
              element.languageCode != 'ar' &&
              element.languageCode != 'ba' &&
              LocaleHelper.transformLocaleToString(element) != 'pt')
          .toList()
        ..sort((a, b) => appLanguage
            .languageName(a.languageCode)
            .toLowerCase()
            .compareTo(appLanguage.languageName(b.languageCode).toLowerCase())),
    ];

    // Initialize focus nodes for each item if needed
    if (_focusNodes.length != _sortedLocales.length) {
      // Dispose previous nodes if any
      for (var node in _focusNodes) {
        node.dispose();
      }

      // Create new focus nodes
      _focusNodes = List.generate(
        _sortedLocales.length,
        (index) => FocusNode(),
      );

      // Find the selected language index
      int selectedIndex = _sortedLocales.indexWhere((locale) =>
          LocaleHelper.transformLocaleToString(appLanguage.appLocal) == LocaleHelper.transformLocaleToString(locale));

      if (selectedIndex != -1) {
        _focusedIndex = selectedIndex;
      }
    }

    // Scroll to the selected language after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToIndex(_focusedIndex);
      // Also request focus for the initial selection
      if (_focusNodes.isNotEmpty && _focusedIndex < _focusNodes.length) {
        _focusNodes[_focusedIndex].requestFocus();
      }
    });

    return FocusScope(
      child: Column(
        children: [
          SizedBox(height: 1.h),
          Text(
            S.of(context).appLang,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
                ),
          ).animate().slideY().fade(),
          SizedBox(height: 1.h),
          Text(
            S.of(context).descLang,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 14.sp,
                  color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
                ),
          ).animate().slideX(begin: .5).fade(),
          SizedBox(height: 1.5.h),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 0.5.h),
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(vertical: 0.5.h),
                itemCount: _sortedLocales.length,
                itemBuilder: (BuildContext context, int index) {
                  var locale = _sortedLocales[index];
                  return AutoScrollTag(
                    key: ValueKey(index),
                    controller: _scrollController,
                    index: index,
                    child: LanguageTile(
                      onSelect: widget.onSelect ??
                          () {
                            if (widget.nextButtonFocusNode != null) {
                              Future.delayed(Duration(milliseconds: 300), () {
                                widget.nextButtonFocusNode!.requestFocus();
                              });
                            }
                          },
                      locale: locale,
                      isSelected: isSelected(LocaleHelper.transformLocaleToString(locale)),
                      focusNode: _focusNodes[index],
                      isFocused: _focusedIndex == index,
                      index: index,
                      onFocusChange: (hasFocus) {
                        if (hasFocus && _focusedIndex != index) {
                          setState(() {
                            _focusedIndex = index;
                          });
                          _scrollToIndex(index);
                        }
                      },
                      onKeyEvent: (event, index) {
                        if (event is RawKeyDownEvent) {
                          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                            _changeFocus(index + 1);
                            return KeyEventResult.handled;
                          }

                          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                            _changeFocus(index - 1);
                            return KeyEventResult.handled;
                          }
                        }
                        return KeyEventResult.ignored;
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageTile extends ConsumerStatefulWidget {
  const LanguageTile({
    Key? key,
    required this.isSelected,
    required this.locale,
    required this.onSelect,
    required this.focusNode,
    required this.isFocused,
    required this.index,
    required this.onFocusChange,
    required this.onKeyEvent,
  }) : super(key: key);

  final bool isSelected;
  final Locale locale;
  final VoidCallback onSelect;
  final FocusNode focusNode;
  final bool isFocused;
  final int index;
  final Function(bool) onFocusChange;
  final Function(RawKeyEvent, int) onKeyEvent;

  @override
  ConsumerState<LanguageTile> createState() => _LanguageTileState();
}

class _LanguageTileState extends ConsumerState<LanguageTile> {
  @override
  Widget build(BuildContext context) {
    final appLanguage = provider.Provider.of<AppLanguage>(context); // Use prefixed Provider
    final mosqueManager = provider.Provider.of<MosqueManager>(context); // Use prefixed Provider

    void handleSelection() {
      appLanguage.changeLanguage(widget.locale, mosqueManager.mosqueUUID);
      widget.onSelect(); // Invoke the callback to navigate
    }

    return Material(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.4.h),
        child: Ink(
          decoration: BoxDecoration(
            color: widget.isFocused
                ? Theme.of(context).focusColor
                : widget.isSelected
                    ? Theme.of(context).focusColor
                    : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Focus(
            focusNode: widget.focusNode,
            autofocus: widget.isSelected,
            onFocusChange: widget.onFocusChange,
            onKey: (node, event) {
              final result = widget.onKeyEvent(event, widget.index);
              if (result == KeyEventResult.handled) {
                return result;
              }

              if (event is RawKeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
                  handleSelection();
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
            child: InkWell(
              onTap: handleSelection,
              borderRadius: BorderRadius.circular(10),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                horizontalTitleGap: 3.w,
                minLeadingWidth: 10.w,
                visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
                textColor: widget.isFocused || widget.isSelected ? Colors.white : null,
                leading: flagIcon(LocaleHelper.transformLocaleToString(widget.locale), size: 5.h),
                title: Text(
                  appLanguage.combinedLanguageName(LocaleHelper.transformLocaleToString(widget.locale)),
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600),
                ),
                trailing: widget.isSelected
                    ? Icon(
                        MawaqitIcons.icon_checked,
                        color: Colors.white,
                        size: 14.sp,
                      )
                    : null,
              ),
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
