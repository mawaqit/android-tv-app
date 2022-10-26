import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/pages/home/widgets/WeatherWidget.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';

class MosqueHeader extends StatelessWidget {
  const MosqueHeader({Key? key, required this.mosque}) : super(key: key);

  final Mosque mosque;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 5, backgroundColor: Colors.red),
              SizedBox(width: 5),
              Text(S.of(context).offline),
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/img/logo.png', width: 50, height: 50),
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: Text(
                    mosque.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      shadows: kHomeTextShadow,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Image.asset('assets/img/logo.png', width: 50, height: 50),
              ],
            ),
          ),
          WeatherWidget(),
        ],
      ),
    );
  }
}
