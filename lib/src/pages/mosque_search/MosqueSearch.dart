import 'package:flutter/material.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/InputTypeSelector.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/MosqueInputSearch.dart';

class MosqueSearch extends StatefulWidget {
  MosqueSearch({Key? key, this.onDone}) : super(key: key);

  final void Function()? onDone;

  @override
  State<MosqueSearch> createState() => _MosqueSearchState();
}

class _MosqueSearchState extends State<MosqueSearch> {
  final navKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (navKey.currentState!.canPop()) {
          navKey.currentState!.pop();
          return false;
        }
        return true;
      },
      child: Navigator(
        key: navKey,
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => InputTypeSelector(onDone: widget.onDone),
        ),
      ),
    );
  }
}
