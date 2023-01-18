import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/MawaqitAboutWidget.dart';
import 'package:mawaqit/src/services/developer_manager.dart';
import 'package:provider/provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int tapCount = 0;
    return CallbackShortcuts(
      bindings: {
        SingleActivator(LogicalKeyboardKey.arrowDown): () {
          tapCount++;
          if (tapCount >= 7) {
            context.read<DeveloperManager>().enableDeveloperOptions();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Macha'Allah 😎 You have activated the Abogabal secret menu رائع 😎 لقد قمت بتنشيط قائمة أبو جبل"),
              ),
            );
            tapCount = 0;
            return;
          }

          EasyDebounce.debounce('tag', Duration(milliseconds: 2000), () {
            tapCount = 0;
          });
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Row(
            children: [
              Expanded(
                flex: 4,
                child: Align(
                  child: Lottie.asset(
                    'assets/animations/lottie/welcome.json',
                    fit: BoxFit.contain,
                  ),
                  alignment: Alignment.center,
                ),
              ),
              Expanded(
                flex: 6,
                child: OnBoardingMawaqitAboutWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
