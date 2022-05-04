import 'package:flutter/material.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/InputTypeSelector.dart';

class MosqueSearch extends StatelessWidget {
  MosqueSearch({Key? key, this.onDone}) : super(key: key);

  final void Function()? onDone;
  final _key = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_key.currentState?.canPop() == true) {
          _key.currentState!.pop();
          return false;
        }

        return true;
      },
      child: Navigator(
        key: _key,
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => InputTypeSelector(onDone: onDone),
        ),
      ),
    );
  }
}
