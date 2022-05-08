import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/MosqueInputId.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/MosqueInputSearch.dart';

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
          // shrinkWrap: true,
          children: [
            Text(
              S.of(context).doYouKnowMosqueId,
              // "Mosque Input",
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: isLight ? theme.primaryColor : Colors.white,
              ),
            ),
            SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MosqueInputId(onDone: onDone)));
              },
              child: Text(S.current.yes),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MosqueInputSearch(onDone: onDone)));
              },
              child: Text(S.current.no),
            ),
          ],
        ),
      ),
    );
  }
}
