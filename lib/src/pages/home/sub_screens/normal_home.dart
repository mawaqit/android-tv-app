import 'package:flutter/material.dart';
import 'package:mawaqit/src/pages/home/widgets/orientation_widget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../../times/normal_home/landscape_normal_home.dart';
import '../../times/normal_home/portrait_normal_home.dart';
import '../../times/turkish_home/landscape_turkish_home.dart';
import '../../times/turkish_home/portrait_turkish_home.dart';

class NormalHomeSubScreen extends StatelessOrientationWidget {
  const NormalHomeSubScreen({super.key});

  @override
  Widget buildLandscape(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();

    if (mosqueManager.times!.isTurki) return LandScapeTurkishHome();

    return LandscapeNormalHome();
  }

  @override
  Widget buildPortrait(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();

    if (mosqueManager.times!.isTurki) return PortraitTurkishHome();

    return PortraitNormalHome();
  }
}
