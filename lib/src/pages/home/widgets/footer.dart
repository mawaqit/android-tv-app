import 'package:flutter/material.dart';
import 'package:mawaqit/src/mawaqit_image/mawaqit_network_image.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:mawaqit/src/pages/home/widgets/FlashWidget.dart';
import 'package:mawaqit/src/pages/home/widgets/HomeLogoVersion.dart';
import 'package:mawaqit/src/pages/home/widgets/MosqueInformationWidget.dart';

const kFooterQrLink = 'https://cdn.mawaqit.net/images/store-qrcode.png?4.89.2';

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.read<MosqueManager>();
    final Mosque? mosque = mosqueManager.mosque;
    final mosqueConfig = mosqueManager.mosqueConfig;
    final TextDirection textDirection = Directionality.of(context);

    if (mosque == null || mosqueConfig == null) {
      return SizedBox();
    }

    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final showMosqueInfo = !isPortrait && mosque.flash == null && mosqueConfig.footer == true;
    final qrCodeSection = Expanded(
      flex: showMosqueInfo ? 2 : 1,
      child: Row(
        children: [
          Flexible(
            child: _buildQrCodeSection(mosque, textDirection),
          ),
        ],
      ),
    );

    final mosqueInfoSection = Expanded(
      flex: 14,
      child: MosqueInformationWidget(),
    );

    final flashWidget = Expanded(
      flex: 14,
      child: FlashWidget(),
    );

    final logoVersionSection = Expanded(
      flex: 2,
      child: Align(
        alignment: AlignmentDirectional.bottomEnd,
        child: HomeLogoVersion(),
      ),
    );

    Widget middleSection;
    if (isPortrait) {
      middleSection = Spacer(flex: 6);
    } else if (mosque.flash != null) {
      middleSection = flashWidget;
    } else if (showMosqueInfo) {
      middleSection = mosqueInfoSection;
    } else {
      middleSection = Spacer(flex: 6);
    }

    return Column(
      children: [
        if (isPortrait && mosque.flash != null)
          Container(
            color: Colors.black26,
            height: 5.h,
            alignment: Alignment.center,
            child: FlashWidget(),
          ),
        Container(
          height: 6.5.h,
          color: mosque.flash?.content.isEmpty != false ? null : Colors.black.withOpacity(.3),
          padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                qrCodeSection,
                middleSection,
                logoVersionSection,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQrCodeSection(Mosque mosque, TextDirection textDirection) {
    return Container(
      margin: textDirection == TextDirection.ltr ? EdgeInsets.only(right: 2.w) : EdgeInsets.only(left: 2.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ID ${mosque.id}",
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontSize: 6.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: kAfterAdhanTextShadow,
            ),
          ),
          SizedBox(height: 0.5.h),
          Expanded(
            child: FittedBox(
              fit: BoxFit.contain,
              child: MawaqitNetworkImage(
                imageUrl: kFooterQrLink,
                errorBuilder: (context, url, error) => SizedBox(),
                width: 5.h,
                height: 5.h,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
