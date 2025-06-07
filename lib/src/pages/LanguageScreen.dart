import 'package:flutter/material.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';
import '../helpers/AppRouter.dart';
import 'onBoarding/widgets/widgets.dart';

class LanguageScreen extends StatelessWidget {
  // Private constructor with all attributes
  const LanguageScreen._({
    Key? key,
    required this.isOnboarding,
    this.onSelect,
    this.languages,
    this.title = "",
    this.description = "",
    this.isIconActivated = true,
    this.isSelected,
  }) : super(key: key);

  final void Function(String)? onSelect;
  final List<String>? languages;
  final bool? isIconActivated;
  final String? title;
  final String? description;
  final bool isOnboarding;
  final bool Function(String)? isSelected;

  // Factory for normal mode
  factory LanguageScreen({
    Key? key,
    void Function(String)? onSelect,
    List<String>? languages,
    String title = "",
    String description = "",
    bool isIconActivated = true,
    bool Function(String)? isSelected,
  }) {
    return LanguageScreen._(
      key: key,
      isOnboarding: false,
      onSelect: onSelect,
      languages: languages,
      title: title,
      description: description,
      isIconActivated: isIconActivated,
      isSelected: isSelected,
    );
  }

  // Factory for onboarding mode
  factory LanguageScreen.onboarding({
    Key? key,
    void Function(String)? onSelect,
    List<String>? languages,
    String title = "",
    String description = "",
    bool isIconActivated = true,
    bool Function(String)? isSelected,
  }) {
    return LanguageScreen._(
      key: key,
      isOnboarding: true,
      onSelect: onSelect,
      languages: languages,
      title: title,
      description: description,
      isIconActivated: isIconActivated,
      isSelected: isSelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWithAnimationWidget(
      animation: R.ASSETS_ANIMATIONS_LOTTIE_LANGUAGE_JSON,
      child: title!.isNotEmpty
          ? LanguageSelector(
              onSelect: (selectedLang) {
                onSelect?.call(selectedLang);
              },
              isSelected: isSelected!,
              languages: languages!,
              title: title!,
              description: description!,
              isIconActivated: isIconActivated!,
            )
          : isOnboarding
              ? OnBoardingLanguageSelector.onboarding()
              : OnBoardingLanguageSelector.normal(
                  onNext: AppRouter.pop,
                ),
    );
  }
}
