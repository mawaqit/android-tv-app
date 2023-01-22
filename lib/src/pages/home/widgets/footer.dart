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
    return mosqueConfig!.footer!
        ? Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              MosqueInformationWidget(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: .5.vw, vertical: .2.vw),
                width: double.infinity,
                color: mosque?.flash?.content.isEmpty != false ? null : Colors.black38,
                child: SizedBox(
                  height: 5.vw,
                  child: Directionality(
                      textDirection: isLTR ? TextDirection.ltr : TextDirection.rtl, child: FlashWidget()),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: .4.vw, vertical: .2.vw),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ID ${mosque?.id}",
                        style: TextStyle(
                          fontSize: .7.vw,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          shadows: kHomeTextShadow,
                        ),
                      ),
                      SizedBox(height: 5),
                      Image.network(
                        'https://mawaqit.net/static/images/store-qrcode.png?4.89.2',
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
                        bottom: 1.vh,
                        left: .5.vw,
                        right: .5.vw,
                        top: .6.vh,
                      ),
                      height: 9.5.vh,
                      child: HomeLogoVersion()),
                ),
              ),
            ],
          )
        : SizedBox(
            height: 5.vw,
          );
  }
}
