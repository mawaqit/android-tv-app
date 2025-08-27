import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/state_management/on_boarding/on_boarding.dart';
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
        final isMosqueSearchSelected = ref.watch(mosqueManagerProvider).fold(() => false, (t) => true);
        final shouldShowFinish = data.shouldShowFinishButton(isMosqueSearchSelected);
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
                  mainAxisAlignment: MainAxisAlignment.end,
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
                      if (data.canSkipCurrentScreen && onSkipPressed != null)
                        MawaqitIconButton(
                          focusNode: nextButtonFocusNode ?? FocusNode(),
                          icon: Icons.navigate_next,
                          label: S.of(context).skip,
                          onPressed: onSkipPressed,
                          isAutoFocus: true,
                        )
                      else if (!data.isMosqueSearchScreen || (data.isMosqueSearchScreen && isMosqueSearchSelected))
                        MawaqitIconButton(
                          focusNode: nextButtonFocusNode ?? FocusNode(),
                          icon: data.isLastItem ? Icons.check : Icons.arrow_forward_rounded,
                          label: shouldShowFinish ? S.of(context).finish : S.of(context).next,
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
