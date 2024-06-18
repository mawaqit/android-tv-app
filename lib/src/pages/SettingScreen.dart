import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;

import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/connectivity_provider.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/models/address_model.dart';
import 'package:mawaqit/src/pages/HijriAdjustmentsScreen.dart';
import 'package:mawaqit/src/pages/LanguageScreen.dart';
import 'package:mawaqit/src/pages/MosqueSearchScreen.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/OrientationWidget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/theme_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/src/state_management/on_boarding/on_boarding_notifier.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';
import 'package:provider/provider.dart' hide Consumer;
import 'package:sizer/sizer.dart';

import '../../i18n/AppLanguage.dart';
import '../../main.dart';

import '../helpers/TimeShiftManager.dart';
import '../services/FeatureManager.dart';
import '../state_management/app_update/app_update_notifier.dart';
import '../state_management/random_hadith/random_hadith_notifier.dart';
import '../widgets/screen_lock_widget.dart';
import '../widgets/time_picker_widget.dart';
import 'home/widgets/show_check_internet_dialog.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TimeShiftManager().initializeTimes();
      await ref.read(onBoardingProvider.notifier).isDeviceRooted();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildSettingScreen(context, ref);
  }

  Widget _buildSettingScreen(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appLanguage = Provider.of<AppLanguage>(context);
    final userPreferences = context.watch<UserPreferencesManager>();
    final themeManager = context.watch<ThemeNotifier>();
    final String checkInternet = S.of(context).noInternet;
    final String hadithLanguage = S.of(context).connectToChangeHadith;
    TimeShiftManager timeShiftManager = TimeShiftManager();
    final featureManager = Provider.of<FeatureManager>(context);

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
                    onTap: () {
                      context.read<AppLanguage>().getHadithLanguage();
                      AppRouter.push(
                        LanguageScreen(
                          isIconActivated: true,
                          title: S.of(context).randomHadithLanguage,
                          description: S.of(context).descLang,
                          languages:
                              appLanguage.hadithLocalizedLanguage.keys.toList(),
                          isSelected: (langCode) {
                            return appLanguage.hadithLanguage == langCode;
                          },
                          onSelect: (langCode) async {
                            await ref
                                .read(connectivityProvider.notifier)
                                .checkInternetConnection();
                            ref.watch(connectivityProvider).maybeWhen(
                              orElse: () {
                                showCheckInternetDialog(
                                  context: context,
                                  onRetry: () {
                                    AppRouter.pop();
                                  },
                                  title: checkInternet,
                                  content: hadithLanguage,
                                );
                              },
                              data: (isConnectedToInternet) {
                                if (isConnectedToInternet ==
                                    ConnectivityStatus.disconnected) {
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
                                  ref
                                      .read(
                                          randomHadithNotifierProvider.notifier)
                                      .fetchAndCacheHadith(language: langCode);
                                  AppRouter.pop();
                                }
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      return _SettingSwitchItem(
                        title: S.of(context).automaticUpdate,
                        subtitle: S.of(context).automaticUpdateDescription,
                        icon: Icon(Icons.update, size: 35),
                        onChanged: (value) {
                          logger.d('setting: disable the update $value');
                          ref
                              .read(appUpdateProvider.notifier)
                              .toggleAutoUpdateChecking();
                        },
                        value: ref.watch(appUpdateProvider).maybeWhen(
                              orElse: () => false,
                              data: (data) => data.isAutoUpdateChecking,
                            ),
                      );
                    },
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
                  featureManager.isFeatureEnabled("timezone_shift") &&
                          timeShiftManager.deviceModel == "MAWABOX" &&
                          timeShiftManager.isLauncherInstalled
                      ? _SettingItem(
                          title: S.of(context).timeSetting,
                          subtitle: S.of(context).timeSettingDesc,
                          icon: Icon(MawaqitIcons.icon_clock, size: 35),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => TimePickerModal(
                                timeShiftManager: timeShiftManager,
                              ),
                            );
                          },
                        )
                      : SizedBox(),
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
                  _screenLock(context, ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _screenLock(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final timeShiftManager = TimeShiftManager();
    final isDeviceRooted = ref.watch(onBoardingProvider).maybeWhen(
          orElse: () => false,
          data: (value) => value.isRootedDevice,
        );
    log('isDeviceRooted: ${isDeviceRooted} - isLauncherInstalled: ${timeShiftManager.isLauncherInstalled}');
    return isDeviceRooted /* && timeShiftManager.isLauncherInstalled */
        ? Column(
            children: [
              Divider(),
              SizedBox(height: 10),
              Text(
                "Device Settings",
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              _SettingItem(
                title: S.of(context).screenLock,
                subtitle: S.of(context).screenLockDesc,
                icon: Icon(Icons.power_settings_new, size: 35),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => ScreenLockModal(
                    timeShiftManager: timeShiftManager,
                  ),
                ),
              ),
            ],
          )
        : SizedBox();
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
                style: TextStyle(fontSize: 10))
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
