import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../../../themes/UIShadows.dart';
import 'FlashWidget.dart';
import 'HomeLogoVersion.dart';
import 'MosqueInformationWidget.dart';

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.read<MosqueManager>();
    final mosqueConfig = mosqueManager.mosqueConfig;
    final mosque = mosqueManager.mosque;
    final isLTR = mosque?.flash?.orientation == "ltr";
    final isArabic = context.read<AppLanguage>().isArabic();
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        if (mosqueConfig!.footer! && (mosque?.flash?.content == null || mosque!.flash!.content.isEmpty) ) MosqueInformationWidget(),
        if (mosqueConfig.footer!)
          Container(
            padding: EdgeInsets.symmetric(horizontal: .5.vw, vertical: .2.vw),
            width: double.infinity,
            color:
                mosque?.flash?.content.isEmpty != false ? null : Colors.black.withOpacity(.3),
            child: SizedBox(
              height: 5.vw,
              child: Directionality(
                  textDirection: isLTR ? TextDirection.ltr : TextDirection.rtl,
                  child: FlashWidget()),
            ),
          ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: .5.vw, vertical: 1.vh),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ID ${mosque?.id}",
                  style: TextStyle(
                    fontSize: 1.1.vw,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: kAfterAdhanTextShadow,
                  ),
                ),
                SizedBox(height: .5.vh),
                CachedNetworkImage(
                  imageUrl:
                      'https://mawaqit.net/static/images/store-qrcode.png?4.89.2',
                  errorWidget: (context, url, error) => SizedBox(),
                  width: 5.vw,
                  height: 5.vw,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Container(
                padding: EdgeInsets.only(
                  bottom: .65.vh,
                  left: .3.vw,
                  right: .1.vw,
                  top: 1.vh,
                ),
                height: 9.5.vh,
                child: HomeLogoVersion()),
          ),
        ),
      ],
    );
  }
}
