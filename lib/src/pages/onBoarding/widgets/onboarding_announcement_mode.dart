import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:provider/provider.dart';

class OnBoardingAnnouncementScreens extends StatelessWidget {
  const OnBoardingAnnouncementScreens({Key? key, this.onDone}) : super(key: key);

  final VoidCallback? onDone;

  setAnnouncementMode(BuildContext context, bool mainScreen) {
    context.read<UserPreferencesManager>().announcementsOnly = mainScreen;
    onDone?.call();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<UserPreferencesManager>();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            S.of(context).announcementOnlyMode,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 25),
          ),
          SizedBox(height: 10),
          Text(
            S.of(context).announcementOnlyModeEXPLINATION,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          OutlinedButton(
            onPressed: () => setAnnouncementMode(context, false),
            child: Text(S.of(context).normalMode),
            autofocus: true,
          ),
          OutlinedButton(
            onPressed: () => setAnnouncementMode(context, true),
            child: Text(S.of(context).announcementOnlyMode),
          ),
        ],
      ),
    );
  }
}
