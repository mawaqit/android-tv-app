import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/pages/home/widgets/WeatherWidget.dart';
import 'package:mawaqit/src/pages/home/widgets/offline_widget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

import '../../../helpers/StringUtils.dart';

class MosqueHeader extends StatelessWidget {
  const MosqueHeader({Key? key, required this.mosque}) : super(key: key);

  final Mosque mosque;

  @override
  Widget build(BuildContext context) {
    final mosqueManger = context.watch<MosqueManager>();

    final mosqueConfig = mosqueManger.mosqueConfig;

    final tr = S.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 1.8.vh, left: .8.vw, right: .8.vw),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OfflineWidget(),
          Spacer(),
          mosque.logo != null && mosqueConfig!.showLogo
              ? CachedNetworkImage(
                  imageUrl: mosque.logo!,
                  width: 40,
                  height: 40,
                )
              : SizedBox(),
          SizedBox(width: 10),
          Container(
              constraints: BoxConstraints(maxWidth: 70.vw),
              child: FittedBox(
                child: Row(
                  children: StringManager.convertStringToList(
                    mosqueConfig!.showCityInTitle
                        ? mosque.name
                        : mosque.name.contains("-")
                            ? mosque.name.substring(0, mosque.name.lastIndexOf("-"))
                            : mosque.name,
                  ).map((e) {
                    bool isArabicText =
                        StringManager.arabicLetters.hasMatch(e) || StringManager.urduLetters.hasMatch(e);
                    return Text(
                      "$e ",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 4.vw,
                          height: isArabicText ? 1.2 : 1,
                          shadows: kIqamaCountDownTextShadow,
                          fontWeight: FontWeight.bold,
                          fontFamily: isArabicText ? StringManager.fontFamilyKufi : null),
                    );
                  }).toList(),
                ),
              )

              // Text(
              //   mosque.name,
              //   maxLines: 1,
              //   style: TextStyle(
              //     color: Colors.white,
              //     fontSize: 4.vw,
              //     height: 1,
              //     shadows: kHomeTextShadow,
              //     fontWeight: FontWeight.bold,
              //     // fontFamily: StringManager.fontFamilyHelvetica
              //   ),
              // ),
              ),
          SizedBox(width: 10),
          mosque.logo != null && mosqueConfig.showLogo
              ? CachedNetworkImage(
                  imageUrl: mosque.logo!,
                  width: 40,
                  height: 40,
                )
              : SizedBox(),
          Spacer(),
          WeatherWidget(),
        ],
      ),
    );
  }
}
