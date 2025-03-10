import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/state_management/on_boarding/v2/onboarding_navigation_notifier.dart';
import 'package:mawaqit/src/widgets/InfoWidget.dart';
import 'package:mawaqit/src/widgets/mawaqit_icon_button.dart';
import 'package:mawaqit/src/widgets/mawaqit_back_icon_button.dart';

class OnboardingBottomNavigationBar extends ConsumerWidget {
  final VoidCallback onPreviousPressed;
  final VoidCallback onNextPressed;
  final FocusNode? nextButtonFocusNode;

  const OnboardingBottomNavigationBar({
    super.key,
    required this.onPreviousPressed,
    required this.onNextPressed,
    this.nextButtonFocusNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNavigationProvider);
    return state.when(
        data: (data) {
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
                      mainAxisAlignment: Directionality.of(context) == TextDirection.ltr
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
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
                        if (data.enableNextButton)
                          MawaqitIconButton(
                            focusNode: nextButtonFocusNode ?? FocusNode(),
                            icon: data.isLastItem ? Icons.check : Icons.arrow_forward_rounded,
                            label: data.isLastItem ? S.of(context).finish : S.of(context).next,
                            onPressed: onNextPressed,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
        },
        error: (e, s) => Container(),
        loading: () => Container());
  }
}
