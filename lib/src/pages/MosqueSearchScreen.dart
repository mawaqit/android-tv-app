import 'package:flutter/material.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/src/pages/mosque_search/MosqueSearch.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';

class MosqueSearchScreen extends StatelessWidget {
  const MosqueSearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenWithAnimationWidget(
      animation: R.ASSETS_ANIMATIONS_LOTTIE_SEARCH_JSON,
      child: MosqueSearch(onDone: () => Navigator.of(context, rootNavigator: true).pop()),
    );
  }
}
