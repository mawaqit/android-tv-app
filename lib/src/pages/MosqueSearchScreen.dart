import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/src/pages/mosque_search/MosqueSearch.dart';

class MosqueSearchScreen extends StatelessWidget {
  const MosqueSearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 4,
            child: Center(
              child: Lottie.asset(
                R.ASSETS_ANIMATIONS_LOTTIE_SEARCH_JSON,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: MosqueSearch(onDone: () => Navigator.of(context, rootNavigator: true).pop()),
          ),
        ],
      ),
    );
  }
}
