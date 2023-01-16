import 'package:flutter/material.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../../../helpers/mawaqit_icons_icons.dart';

class MosqueInformationWidget extends StatelessWidget {
  const MosqueInformationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosque = context.read<MosqueManager>().mosque;
    String phoneNumber = "${mosque?.phone!=null ?mosque!.phone:""} ";
    String association = "${mosque?.association!=null ?mosque?.association:""} ";
    // String bank = "${mosque?.} ";

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(association),
          mosque!.phone != null ? Icon(Icons.phone_iphone) : SizedBox(),
          Text(phoneNumber ),
        ],
      ),
    );
  }
}
