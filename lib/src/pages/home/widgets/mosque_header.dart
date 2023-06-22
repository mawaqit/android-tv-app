import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/mawaqit_image/mawaqit_network_image.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/pages/home/widgets/WeatherWidget.dart';
import 'package:mawaqit/src/pages/home/widgets/offline_widget.dart';
import 'package:mawaqit/src/pages/home/widgets/orientation_widget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:text_scroll/text_scroll.dart';

class MosqueHeader extends StatelessOrientationWidget {
  const MosqueHeader({Key? key, required this.mosque}) : super(key: key);

  final Mosque mosque;

  @override
  Widget buildLandscape(BuildContext context) {
    final mosqueConfig = context.watch<MosqueManager>().mosqueConfig;

    return Padding(
      padding: EdgeInsets.only(top: 1.8.vh, left: .8.vw, right: .8.vw),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OfflineWidget(),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                mosque.logo != null && mosqueConfig!.showLogo
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MawaqitNetworkImage(
                          imageUrl: mosque.logo!,
                          width: 40,
                          height: 40,
                          errorBuilder: (context, error, stackTrace) => SizedBox(),
                        ),
                      )
                    : SizedBox(),
                // SizedBox(width: 10),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.only(left: 1.vw),
                    child: StatefulBuilder(
                      key: ValueKey(mosque.name.hashCode ^ SizerUtil.orientation.hashCode),
                      builder: (context, setState) => TextScroll(
                        mosque.name,
                        intervalSpaces: 10,
                        pauseBetween: 3.seconds,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 4.vwr,
                          height: 1.2,
                          shadows: kIqamaCountDownTextShadow,
                          fontWeight: FontWeight.bold,
                          // fontFamily: StringManager.fontFamilyKufi,
                        ),
                      ),
                    ),
                  ),
                ),

                // SizedBox(width: 10),
                mosque.logo != null && mosqueConfig!.showLogo
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MawaqitNetworkImage(
                          imageUrl: mosque.logo!,
                          width: 40,
                          height: 40,
                          errorBuilder: (context, error, stackTrace) => SizedBox(),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
          WeatherWidget(),
        ],
      ),
    );
  }

  @override
  Widget buildPortrait(BuildContext context) {
    final mosqueConfig = context.watch<MosqueManager>().mosqueConfig;

    return Padding(
      padding: EdgeInsets.only(top: 1.8.vh, left: .8.vw, right: .8.vw),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OfflineWidget(),
              WeatherWidget(),
            ],
          ),
          SizedBox(height: 1.8.vh),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (mosque.logo != null && mosqueConfig!.showLogo)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MawaqitNetworkImage(imageUrl: mosque.logo!, width: 40, height: 40),
                ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.only(left: 1.vw),
                  child: StatefulBuilder(
                    builder: (context, setState) => TextScroll(
                      key: ValueKey(mosque.name.hashCode ^ SizerUtil.orientation.hashCode),
                      mosque.name,
                      intervalSpaces: 10,
                      pauseBetween: 3.seconds,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 4.vwr,
                        height: 1.2,
                        shadows: kIqamaCountDownTextShadow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // SizedBox(width: 10),
              if (mosque.logo != null && mosqueConfig!.showLogo)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MawaqitNetworkImage(
                    imageUrl: mosque.logo!,
                    width: 40,
                    height: 40,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
