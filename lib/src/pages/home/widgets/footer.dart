import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
    final mosque = mosqueManager.mosque;

    return Container(
      height: 10.vh,
      color: mosque?.flash?.content.isEmpty != false
          ? null
          : Colors.black.withOpacity(.3),
      padding: EdgeInsets.symmetric(horizontal: .3.vw, vertical: .5.vw),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    heightFactor: 0,
                    alignment: Alignment(-1, 1),
                    child: Text(
                      "ID ${mosque?.id}",
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontSize: .8.vw,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: kAfterAdhanTextShadow,
                      ),
                    ),
                  ),
                  SizedBox(height: .5.vh),
                  Expanded(
                    child: FittedBox(
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://mawaqit.net/static/images/store-qrcode.png?4.89.2',
                        errorWidget: (context, url, error) => SizedBox(),
                        width: 4.3.vw,
                        height: 4.3.vw,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: mosque?.flash != null
                  ? FlashWidget()
                  : mosqueManager.mosqueConfig?.footer == true
                      ? MosqueInformationWidget()
                      : SizedBox(),
            ),
            HomeLogoVersion(),
          ],
        ),
      ),
    );
  }
}
