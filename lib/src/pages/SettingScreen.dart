import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/pages/HijriAdjustmentsScreen.dart';
import 'package:mawaqit/src/pages/LanguageScreen.dart';
import 'package:mawaqit/src/pages/MosqueSearchScreen.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/OrientationWidget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/theme_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../i18n/AppLanguage.dart';
import 'home/widgets/show_check_internet_dialog.dart';

/// allow user to change the app settings
class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLanguage = Provider.of<AppLanguage>(context);
    final mosqueProvider = context.watch<MosqueManager>();
    final userPreferences = context.watch<UserPreferencesManager>();
    final themeManager = context.watch<ThemeNotifier>();
    final String checkInternet = S.of(context).noInternet;
    final String hadithLanguage = S.of(context).connectToChangeHadith;
    return ScreenWithAnimationWidget(
      animation: 'settings',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(S.of(context).settings, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 20),
            Flexible(
              fit: FlexFit.loose,
              child: ListView(
                shrinkWrap: true,
                children: [
                  _SettingItem(
                    title: S.of(context).changeMosque,
                    subtitle: S.of(context).searchMosque,
                    icon: Icon(MawaqitIcons.icon_mosque, size: 35),
                    onTap: () => AppRouter.push(MosqueSearchScreen()),
                  ),
                  _SettingItem(
                    title: S.of(context).hijriAdjustments,
                    subtitle: S.of(context).hijriAdjustmentsDescription,
                    icon: Icon(MawaqitIcons.icon_mosque, size: 35),
                    onTap: () => AppRouter.push(HijriAdjustmentsScreen()),
                  ),
                  _SettingItem(
                    title: S.of(context).languages,
                    subtitle: S.of(context).descLang,
                    icon: Icon(Icons.language, size: 35),
                    onTap: () => AppRouter.push(LanguageScreen()),
                  ),
                  _SettingItem(
                    title: S.of(context).randomHadithLanguage,
                    subtitle: S.of(context).hadithLangDesc,
                    icon: Icon(Icons.language, size: 35),
                    onTap: () => AppRouter.push(
                      LanguageScreen(
                        isIconActivated: true,
                        title: S.of(context).randomHadithLanguage,
                        description: S.of(context).descLang,
                        languages:
                            appLanguage.hadithLocalizedLanguage.keys.toList(),
                        isSelected: (langCode) =>
                            appLanguage.hadithLanguage == langCode,
                        onSelect: (langCode) {
                          bool isConnectedToInternet = mosqueProvider.isOnline;
                          if (!isConnectedToInternet) {
                            showCheckInternetDialog(
                              context: context,
                              onRetry: () {
                                AppRouter.pop();
                              },
                              title: checkInternet,
                              content: hadithLanguage,
                            );
                          } else {
                            context
                                .read<AppLanguage>()
                                .setHadithLanguage(langCode);
                            AppRouter.pop();
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Divider(),
                  SizedBox(height: 10),
                  Text(
                    S.of(context).applicationModes,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  _SettingSwitchItem(
                    title: theme.brightness == Brightness.light
                        ? S.of(context).darkMode
                        : S.of(context).lightMode,
                    icon: Icon(Icons.brightness_4, size: 35),
                    onChanged: (value) => themeManager.toggleMode(),
                    value: themeManager.isLightTheme ?? false,
                  ),
                  _SettingItem(
                    title: S.of(context).orientation,
                    subtitle: S.of(context).selectYourMawaqitTvAppOrientation,
                    icon: Icon(Icons.portrait, size: 35),
                    onTap: () => AppRouter.push(ScreenWithAnimationWidget(
                      animation: 'welcome',
                      child: OnBoardingOrientationWidget(
                        onSelect: () => Navigator.pop(context),
                      ),
                    )),
                  ),
                  if (!userPreferences.webViewMode)
                    _SettingSwitchItem(
                      title: S.of(context).announcementOnlyMode,
                      subtitle: S.of(context).announcementOnlyModeEXPLINATION,
                      icon: Icon(Icons.notifications, size: 35),
                      value: userPreferences.announcementsOnly,
                      onChanged: (value) =>
                          userPreferences.announcementsOnly = value,
                    ),
                  if (!userPreferences.webViewMode &&
                      !userPreferences.announcementsOnly)
                    _SettingSwitchItem(
                      title: S.of(context).secondaryScreen,
                      subtitle: S.of(context).secondaryScreenExplanation,
                      value: userPreferences.isSecondaryScreen,
                      icon: Icon(Icons.monitor, size: 35),
                      onChanged: (value) =>
                          userPreferences.isSecondaryScreen = value,
                    ),
                  _SettingSwitchItem(
                    title: S.of(context).webView,
                    subtitle: S
                        .of(context)
                        .ifYouAreFacingAnIssueWithTheAppActivateThis,
                    icon: Icon(Icons.online_prediction, size: 35),
                    value: userPreferences.webViewMode,
                    onChanged: (value) => userPreferences.webViewMode = value,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
  }) : super(key: key);

  final String title;
  final String? subtitle;
  final Widget? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        autofocus: true,
        leading: icon ?? SizedBox(),
        trailing: Icon(Icons.arrow_forward_ios),
        title: Text(title),
        subtitle: subtitle != null
            ? Text(subtitle!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 10, color: Colors.white.withOpacity(0.7)))
            : null,
        onTap: onTap,
      ),
    );
  }
}

class _SettingSwitchItem extends StatelessWidget {
  const _SettingSwitchItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.value = false,
    this.icon,
    this.onChanged,
  }) : super(key: key);

  final String title;
  final String? subtitle;
  final Widget? icon;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile(
        autofocus: true,
        secondary: icon ?? SizedBox(),
        title: Text(title),
        subtitle: subtitle != null
            ? Text(subtitle!, maxLines: 2, overflow: TextOverflow.clip)
            : null,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
