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

    return Theme(
      data: theme.copyWith(
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(
              isLight ? null : Colors.white,
            ),
          ),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            // shrinkWrap: true,
            children: [
              Text(
                S.of(context).mosqueInput,
                // "Mosque Input",
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: isLight ? theme.primaryColor : Colors.white,
                ),
                // style: TextStyle(
                //   fontSize: 25.0,
                //   fontWeight: FontWeight.w700,
                //   color: theme.brightness == Brightness.dark ? null : theme.primaryColor,
                // ),
              ),
              SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MosqueInputId(onDone: onDone)));
                },
                child: Text(S.current.selectWithMosqueId),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MosqueInputSearch(onDone: onDone)));
                },
                child: Text(S.current.searchForMosque),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
