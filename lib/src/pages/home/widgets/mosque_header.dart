import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/pages/home/widgets/WeatherWidget.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

import '../../../enum/connectivity_status.dart';
import '../../../helpers/StringUtils.dart';

class MosqueHeader extends StatelessWidget {
  const MosqueHeader({Key? key, required this.mosque}) : super(key: key);

  final Mosque mosque;

  @override
  Widget build(BuildContext context) {
    final isArabic = context.read<AppLanguage>().isArabic();
    var connectionStatus = Provider.of<ConnectivityStatus>(context);
    bool isOffline = connectionStatus == ConnectivityStatus.Offline;
    final tr = S.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 1.8.vh, left: .8.vw, right: .8.vw),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: .5.vh, horizontal: .35.vw),
            child: Directionality(
              textDirection: isArabic?TextDirection.rtl:TextDirection.ltr,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: .6.vw,
                    backgroundColor: isOffline ? Colors.red[700] : Colors.green,
                  ),
                  SizedBox(width: .4.vw),
                  Text(
                    "${isOffline ? tr.offline : tr.online}",
                    style: TextStyle(
                        color: Colors.white,
                        shadows: kHomeTextShadow,
                        fontSize: 1.5.vw,
                        height: 1.1,
                        fontWeight: FontWeight.w400,
                        fontFamily: StringManager.getFontFamily(context)),
                  ),
                ],
              ),
            ),
          ),
          Spacer(),
          mosque.logo != null ? Image.network(mosque.logo!, width: 40, height: 40) : SizedBox(),
          SizedBox(width: 10),
          Container(
            constraints: BoxConstraints(maxWidth: 70.vw),
            child: Text(
              mosque.name,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontSize: 4.vw,
                height: 1,
                shadows: kHomeTextShadow,
                fontWeight: FontWeight.bold,
                // fontFamily: StringManager.fontFamilyHelvetica
              ),
            ),
          ),
          SizedBox(width: 10),
          mosque.logo != null ? Image.network(mosque.logo!, width: 40, height: 40) : SizedBox(),
          Spacer(),
          WeatherWidget(),
        ],
      ),
    );
  }
}
