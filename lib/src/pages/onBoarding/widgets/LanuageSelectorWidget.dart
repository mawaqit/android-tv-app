import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/helpers/post_frame_callback.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class OnBoardingLanguageSelector extends StatefulWidget {
  OnBoardingLanguageSelector({
    Key? key,
    required this.onSelect,
    this.focusNode,
    this.launchTutorial = false,
  }) : super(key: key);

  /// focus node of the first item used to show off the tutorial
  final FocusNode? focusNode;
  final void Function() onSelect;
  final bool launchTutorial;

  @override
  State<OnBoardingLanguageSelector> createState() => _OnBoardingLanguageSelectorState();
}

class _OnBoardingLanguageSelectorState extends State<OnBoardingLanguageSelector> with PostFrameCallback {
  /// this is used to highlight the first item on onboarding
  final firstItemKey = GlobalKey();
  late final targets = [
    TargetFocus(
      shape: ShapeLightFocus.RRect,
      radius: 10,
      contents: [
        TargetContent(
          builder: (context, controller) => _OnBoardingWidget(
            controller: controller,
            title: S.of(context).movingBetweenItems,
            subTitle: S.of(context).movingBetweenItemsEXPLAINATION,
            activate: (event) {
              if ([
                LogicalKeyboardKey.arrowUp,
                LogicalKeyboardKey.arrowDown,
                LogicalKeyboardKey.arrowLeft,
                LogicalKeyboardKey.arrowRight,
              ].contains(event.logicalKey)) {
                return true;
              }

              return false;
            },
            icon: Image.asset(
              R.ASSETS_IMG_ARROW_KEYS_PNG,
              height: 100,
              color: Colors.white.withOpacity(.6),
            ),
          ),
        ),
      ],
      keyTarget: firstItemKey,
    ),
    TargetFocus(
      shape: ShapeLightFocus.RRect,
      radius: 10,
      contents: [
        TargetContent(
          builder: (context, controller) => _OnBoardingWidget(
            controller: controller,
            activate: (event) {
              if (event.logicalKey == LogicalKeyboardKey.enter) {
                return true;
              }

              return false;
            },
            title: S.of(context).selectingItem,
            subTitle: S.of(context).selectingItemEXPLAINATION,
            icon: Image.asset(
              R.ASSETS_IMG_OK_PNG,
              height: 100,
              color: Colors.white.withOpacity(.6),
            ),
          ),
        ),
      ],
      keyTarget: firstItemKey,
    ),
  ];

  @override
  void afterFirstFrame() {
    if (widget.launchTutorial)
      TutorialCoachMark(
        targets: targets,
      ).show(context: context);
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
                  key: index == 0 ? firstItemKey : null,
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
    this.focusNode,
  }) : super(key: key);

  final FocusNode? focusNode;
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
            focusNode: widget.focusNode,
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

class _OnBoardingWidget extends StatelessWidget {
  const _OnBoardingWidget({
    Key? key,
    required this.controller,
    this.title,
    this.subTitle,
    this.icon,
    this.activate,
  }) : super(key: key);

  final TutorialCoachMarkController controller;

  final String? title;
  final String? subTitle;
  final Widget? icon;

  /// if null all keys will be accepted
  final bool Function(RawKeyEvent event)? activate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Focus(
      focusNode: FocusNode()..requestFocus(),
      onKey: (node, event) {
        if (activate?.call(event) ?? true) {
          controller.next();

          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      canRequestFocus: true,
      autofocus: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (title != null) Text(title!, style: theme.textTheme.headlineMedium).animate().slideY().fade(),
          if (subTitle != null) Text(subTitle!).animate(delay: .3.seconds).slideY().fade(),
          SizedBox(height: 50),
          if (icon != null) icon!.animate(delay: .5.seconds).scale().fade(),
        ],
      ),
    );
  }
}
