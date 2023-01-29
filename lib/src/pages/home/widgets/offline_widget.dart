import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

class OfflineWidget extends StatefulWidget {
  const OfflineWidget({Key? key}) : super(key: key);

  @override
  State<OfflineWidget> createState() => _OfflineWidgetState();
}

class _OfflineWidgetState extends State<OfflineWidget> {
  bool isOffline = true;

  checkIsOnline(MosqueManager mosqueManager) async {
    final value = await Api.checkTheInternetConnection();

    setState(() => isOffline = !value);
  }

  @override
  void initState() {
    final mosqueManager = context.read<MosqueManager>();

    checkIsOnline(mosqueManager);
    Stream.periodic(Duration(minutes: 1), (i) => checkIsOnline(mosqueManager));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tr = S.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: .5.vh, horizontal: .35.vw),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 1.vw),
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
    );
  }
}
