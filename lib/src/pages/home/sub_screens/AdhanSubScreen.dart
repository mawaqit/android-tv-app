import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/services/audio_manager.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../../../../generated/assets.dart';

class AdhanSubScreen extends StatefulWidget {
  const AdhanSubScreen({Key? key}) : super(key: key);

  @override
  State<AdhanSubScreen> createState() => _AdhanSubScreenState();
}

class _AdhanSubScreenState extends State<AdhanSubScreen> {
  @override
  void initState() {
    final mosqueManager = context.read<MosqueManager>();
    final salahIndex = mosqueManager.salahIndex;
    final mosqueConfig = mosqueManager.mosqueConfig;
    final audioProvider = context.read<AudioManager>();
    if (mosqueConfig?.adhanEnabledByPrayer![salahIndex] == "1" ||
        (mosqueConfig?.wakeForFajrTime != null && mosqueManager.salahIndex == 0)) {
      if (mosqueConfig?.adhanVoice != null) {
      audioProvider.loadAdhanVoice(mosqueConfig);
      audioProvider.playAdhan();
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  // transform: GradientRotation(pi / 2),
                  begin: Alignment(0, 0),
                  end: Alignment(0, 1),
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withOpacity(0),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: Text(
                      S.of(context).alAdhan,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    "الأذان",
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Image.asset(R.ASSETS_ICON_ADHAN_ICON_PNG),
        ),
      ],
    );
  }
}
