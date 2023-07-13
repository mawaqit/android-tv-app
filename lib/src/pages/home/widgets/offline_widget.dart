import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

class OfflineWidget extends StatelessWidget {
  const OfflineWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.read<MosqueManager>();
    final tr = S.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: .5.vh, horizontal: .35.vw),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 1.vw),
          CircleAvatar(
            radius: .6.vwr,
            backgroundColor: mosqueManager.isOnline ? Colors.green : Colors.red[700],
          ),
          SizedBox(width: .4.vwr),
          Text(
            mosqueManager.isOnline ? tr.online : tr.offline,
            style: TextStyle(
              color: Colors.white,
              shadows: kHomeTextShadow,
              fontSize: 1.5.vwr,
              height: 1.1,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
