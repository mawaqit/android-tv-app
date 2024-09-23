import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/mawaqit_image/mawaqit_network_image.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../../../models/mosque.dart';
import '../../../themes/UIShadows.dart';
import 'FlashWidget.dart';
import 'HomeLogoVersion.dart';
import 'MosqueInformationWidget.dart';

const kFooterQrLink = 'https://mawaqit.net/static/images/store-qrcode.png?4.89.2';

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.read<MosqueManager>();
    final mosque = mosqueManager.mosque!;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final showMosqueInfo = !isPortrait && mosque?.flash == null && mosqueManager.mosqueConfig?.footer == true;

    return Column(
      children: [
        if (isPortrait && mosque.flash != null)
          Container(
            color: Colors.black26,
            height: 5.vh,
            alignment: Alignment.center,
            child: FlashWidget(),
          ),
        Container(
          height: 10.vr,
          color: mosque?.flash?.content.isEmpty != false ? null : Colors.black.withOpacity(.3),
          padding: EdgeInsets.symmetric(horizontal: .3.vw, vertical: .5.vw),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                if (showMosqueInfo)
                  Expanded(
                    flex: 2,
                    child: _buildQrCodeSection(mosque),
                  )
                else
                  _buildQrCodeSection(mosque),
                if (isPortrait)
                  Spacer()
                else if (mosque?.flash != null)
                  Expanded(child: FlashWidget())
                else if (showMosqueInfo)
                  Expanded(
                    flex: 4,
                    child: MosqueInformationWidget(),
                  ),
                if (showMosqueInfo)
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: HomeLogoVersion(),
                    ),
                  )
                else
                  HomeLogoVersion(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQrCodeSection(Mosque? mosque) {
    return IntrinsicWidth(
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
                fontSize: .8.vwr,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: kAfterAdhanTextShadow,
              ),
            ),
          ),
          SizedBox(height: .5.vh),
          Expanded(
            child: FittedBox(
              child: MawaqitNetworkImage(
                imageUrl: kFooterQrLink,
                errorBuilder: (context, url, error) => SizedBox(),
                width: 4.3.vwr,
                height: 4.3.vwr,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
