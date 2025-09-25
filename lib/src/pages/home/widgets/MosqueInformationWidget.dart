import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../helpers/mawaqit_icons_icons.dart';

class MosqueInformationWidget extends StatelessWidget {
  const MosqueInformationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosque = context.read<MosqueManager>().mosque;
    String phoneNumber = "${mosque?.phone != null ? mosque!.phone : ""} ";
    String association = "${mosque?.association != null ? mosque?.association : ""} ";
    String website = "${mosque?.site != null && mosque!.site!.isNotEmpty ? mosque.site : ""} ";
    String email = "${mosque?.email != null && mosque!.email!.isNotEmpty ? mosque.email : ""} ";

    log('Mosque phone: ${mosque?.phone}');
    log('Mosque website: ${mosque?.site}');
    log('Mosque email: ${mosque?.email}');

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.5.vh, horizontal: 2.w),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              association,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (mosque!.phone != null) ...[
              SizedBox(width: 2.w),
              Icon(
                Icons.phone_iphone,
                color: Colors.white,
                size: 12.sp,
              ),
              SizedBox(width: 1.w),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  phoneNumber,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (mosque.site != null && mosque.site!.isNotEmpty) ...[
              SizedBox(width: 2.w),
              Icon(
                Icons.language,
                color: Colors.white,
                size: 12.sp,
              ),
              SizedBox(width: 1.w),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  website,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (mosque.email != null && mosque.email!.isNotEmpty) ...[
              SizedBox(width: 2.w),
              Icon(
                Icons.email,
                color: Colors.white,
                size: 12.sp,
              ),
              SizedBox(width: 1.w),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  email,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
