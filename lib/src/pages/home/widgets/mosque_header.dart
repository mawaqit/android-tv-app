import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/pages/home/widgets/WeatherWidget.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';

class MosqueHeader extends StatelessWidget {
  const MosqueHeader({Key? key, required this.mosque}) : super(key: key);

  final Mosque mosque;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: .5.vw, backgroundColor: Colors.red[700]),
          SizedBox(width: .4.vw),
          Text(
            S.of(context).offline,
            style: TextStyle(
              color: Colors.white,
              shadows: kHomeTextShadow,
              fontSize: 1.3.vw,
              height: .8,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Image.asset('assets/img/logo.png', width: 40, height: 40),
          SizedBox(width: 10),
          Container(
            constraints: BoxConstraints(maxWidth: 60.vw),
            child: Text(
              mosque.name,
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: TextStyle(
                color: Colors.white,
                fontSize: 4.vw,
                height: 1,
                shadows: kHomeTextShadow,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 10),
          Image.asset('assets/img/logo.png', width: 40, height: 40),
          Spacer(),
          WeatherWidget(),
        ],
      ),
    );
  }
}
