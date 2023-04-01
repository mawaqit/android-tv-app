import 'package:flutter/material.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../../../../i18n/l10n.dart';

/// select if this is the main mosque screen or secondary one
class OnBoardingScreenType extends StatelessWidget {
  const OnBoardingScreenType({Key? key, this.onDone}) : super(key: key);

  final VoidCallback? onDone;

  setMainScree(BuildContext context, bool mainScreen) {
    context.read<MosqueManager>().isMainScreen = mainScreen;
    onDone?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            S.of(context).mainScreenOrSecondaryScreen,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 25),
          ),
          SizedBox(height: 10),
          Text(
            S.of(context).mainScreenOrSecondaryScreenEXPLINATION,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          OutlinedButton(
            onPressed: () => setMainScree(context, true),
            child: Text(S.of(context).mainScreen),
            autofocus: true,
          ),
          OutlinedButton(
            onPressed: () => setMainScree(context, false),
            child: Text(S.of(context).secondaryScreen),
          ),
        ],
      ),
    );
  }
}
