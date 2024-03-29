import 'package:flutter/material.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/MosqueInputId.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/MosqueInputSearch.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../i18n/l10n.dart';

class InputTypeSelector extends StatelessWidget {
  const InputTypeSelector({Key? key, this.onDone}) : super(key: key);

  final void Function()? onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              S.of(context).doYouKnowMosqueId,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: isLight ? theme.primaryColor : Colors.white,
              ),
            ),
            SizedBox(height: 10),
            OutlinedButton(
              autofocus: true,
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    child: MosqueInputId(onDone: onDone),
                    type: PageTransitionType.fade,
                    alignment: Alignment.center,
                  ),
                );
              },
              child: Text(S.current.yes),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    child: MosqueInputSearch(onDone: onDone),
                    type: PageTransitionType.fade,
                    alignment: Alignment.center,
                  ),
                );
              },
              child: Text(S.current.no),
            ),
          ],
        ),
      ),
    );
  }
}
