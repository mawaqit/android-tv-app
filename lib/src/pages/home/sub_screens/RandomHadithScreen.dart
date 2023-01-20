import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/pages/home/widgets/AboveSalahBar.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahTimesBar.dart';

import '../../../helpers/StringUtils.dart';

class RandomHadithScreen extends StatelessWidget {
  const RandomHadithScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<String>(
            future: Api.randomHadith(),
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: AutoSizeText(
                    snapshot.data?.padRight(500) ?? '',
                    stepGranularity: 12,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 62,
                      fontWeight: FontWeight.bold,
                      fontFamily: StringManager.getFontFamily(context),
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        AboveSalahBar(),
        SizedBox(height: 5),
        SalahTimesBar(),
        SizedBox(height: 10),
      ],
    );
  }
}
