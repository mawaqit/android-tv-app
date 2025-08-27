import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/src/pages/mosque_search/MosqueSearch.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';

class MosqueSearchScreen extends StatelessWidget {
  MosqueSearchScreen({
    Key? key,
    required this.nextButtonFocusNode,
  }) : super(key: key);

  fp.Option<FocusNode> nextButtonFocusNode = fp.Option.fromNullable(null);

  @override
  Widget build(BuildContext context) {
    return ScreenWithAnimationWidget(
      animation: R.ASSETS_ANIMATIONS_LOTTIE_SEARCH_JSON,
      child: MosqueSearch(
        onDone: () => Navigator.of(context, rootNavigator: true).pop(),
        nextButtonFocusNode: nextButtonFocusNode,
      ),
    );
  }
}
