import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/helpers/AppConfig.dart';
import 'package:mawaqit/src/helpers/HexColor.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/MousqeSelectorWidget.dart';
import 'package:mawaqit/src/services/settings_manager.dart';
import 'package:provider/provider.dart';

class MosqueSearchScreen extends StatelessWidget {
  const MosqueSearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsManager = Provider.of<SettingsManager>(context);
    final settings = settingsManager.settings;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor(settings.secondColor),
        title: Text(S.of(context).mosque),
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FractionallySizedBox(
                widthFactor: .75,
                child: Material(
                  color: AppColors().mainColor(.3),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 40,
                    ),
                    child: OnBoardingMosqueSelector(
                      onDone: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
