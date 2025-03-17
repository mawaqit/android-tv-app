import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/state_management/on_boarding/v2/onboarding_navigation_notifier.dart';
import 'package:mawaqit/src/state_management/on_boarding/v2/onboarding_navigation_state.dart';
import 'package:mawaqit/src/state_management/on_boarding/v2/search_selection_type_provider.dart';
import 'package:mawaqit/src/widgets/InfoWidget.dart';
import 'package:mawaqit/src/widgets/mawaqit_icon_button.dart';
import 'package:mawaqit/src/widgets/mawaqit_back_icon_button.dart';

class OnboardingBottomNavigationBar extends ConsumerWidget {
  final VoidCallback onPreviousPressed;
  final VoidCallback onNextPressed;
  final FocusNode? nextButtonFocusNode;
  final VoidCallback? onSkipPressed;

  const OnboardingBottomNavigationBar({
    super.key,
    required this.onPreviousPressed,
    required this.onNextPressed,
    this.nextButtonFocusNode,
    this.onSkipPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNavigationProvider);

    return state.when(
      data: (data) {
        final screenType = data.screenFlow[data.currentScreen];
        final isMosqueSearch = switch (screenType) {
          OnboardingScreenType.mosqueId || OnboardingScreenType.mosqueName => true,
          OnboardingScreenType.chromecastMosqueId || OnboardingScreenType.chromecastMosqueName => true,
          _ => false
        };
        final isMosqueSearchSelected = ref.watch(mosqueManagerProvider).fold(() => false, (t) => true);

        // Check if current screen is country or timezone selection
        final isCountryOrTimezoneScreen =
            screenType == OnboardingScreenType.countrySelection || screenType == OnboardingScreenType.timezoneSelection;
        return Container(
          padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: VersionWidget(
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(.5),
                  ),
                ),
              ),
              const Expanded(flex: 1, child: SizedBox()),
              DotsIndicator(
                dotsCount: data.screenFlow.length,
                position: data.currentScreen,
                decorator: DotsDecorator(
                  size: const Size.square(9.0),
                  activeSize: const Size(21.0, 9.0),
                  activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  spacing: const EdgeInsets.all(3),
                ),
              ),
              const Expanded(flex: 1, child: SizedBox()),
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment:
                      Directionality.of(context) == TextDirection.ltr ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: data.enablePreviousButton,
                      replacement: Opacity(
                        opacity: 0,
                        child: MawaqitBackIconButton(
                          icon: Icons.arrow_back_rounded,
                          label: S.of(context).previous,
                          onPressed: onPreviousPressed,
                        ),
                      ),
                      child: MawaqitBackIconButton(
                        icon: Icons.arrow_back_rounded,
                        label: S.of(context).previous,
                        onPressed: onPreviousPressed,
                      ),
                    ),
                    if (data.enablePreviousButton) const SizedBox(width: 5),

                    // Fixed conditional widget section
                    if (data.enableNextButton)
                      // Only show the button when it's either:
                      // 1. Not a mosque search screen, OR
                      // 2. A mosque search screen WITH a mosque selected
                      if (isCountryOrTimezoneScreen && onSkipPressed != null)
                        MawaqitBackIconButton(
                          icon: Icons.navigate_next,
                          label: S.of(context).skip,
                          onPressed: onSkipPressed,
                          isAutoFocus: true,
                        )
                      else if (!isMosqueSearch || (isMosqueSearch && isMosqueSearchSelected))
                        MawaqitIconButton(
                          focusNode: nextButtonFocusNode ?? FocusNode(),
                          icon: data.isLastItem ? Icons.check : Icons.arrow_forward_rounded,
                          label: data.isLastItem ? S.of(context).finish : S.of(context).next,
                          onPressed: onNextPressed,
                        )
                      else
                        // Show disabled button when on mosque search without selection
                        Opacity(
                          opacity: 0.5,
                          child: MawaqitIconButton(
                            focusNode: nextButtonFocusNode ?? FocusNode(),
                            icon: Icons.arrow_forward_rounded,
                            label: S.of(context).next,
                            onPressed: null, // Disabled button
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      error: (e, s) => Container(),
      loading: () => Container(),
    );
  }
}
