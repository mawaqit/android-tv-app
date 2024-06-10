import 'package:flutter/material.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';

import '../helpers/AppRouter.dart';
import 'onBoarding/widgets/onboarding_language_selector.dart';
import 'onBoarding/widgets/language_selector_widget.dart';

class LanguageScreen extends StatelessWidget {
  final void Function(String)? onSelect;
  final List<String>? languages; // List of language codes
  final bool? isIconActivated;
  final String? title;
  final String? description;
  String selectedLanguage = "";

  final bool Function(String)? isSelected;

  LanguageScreen({
    Key? key,
    this.onSelect,
    this.languages, // List of languages
    this.title = "",
    this.description = "", // Description of the screen
    this.isIconActivated = true,
    this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenWithAnimationWidget(
      animation: R.ASSETS_ANIMATIONS_LOTTIE_LANGUAGE_JSON,
      // child:  OnBoardingLanguageSelector(onSelect: AppRouter.pop)
      child: title!.isNotEmpty
          ? LanguageSelector(
              onSelect: (selectedLang) {
                onSelect?.call(selectedLang); // Call the passed onSelect with the selected language
              },
              isSelected: isSelected!,
              languages: languages!,
              title: title!,
              description: description!,
              isIconActivated: isIconActivated!,
            )
          : OnBoardingLanguageSelector(onSelect: AppRouter.pop),
    );
  }
// AppBar _renderAppBar(context) {
//   final settingsManager = Provider.of<SettingsManager>(context);
//   final settings = settingsManager.settings;
//
//   return AppBar(
//       title: Text(
//         S.of(context).languages,
//         style: TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold),
//       ),
//       flexibleSpace: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//             colors: <Color>[
//               Theme.of(context).brightness == Brightness.light
//                   ? HexColor(settings.firstColor)
//                   : Theme.of(context).primaryColor,
//               Theme.of(context).brightness == Brightness.light
//                   ? HexColor(settings.secondColor)
//                   : Theme.of(context).primaryColor,
//             ],
//           ),
//         ),
//       ));
// }
}
