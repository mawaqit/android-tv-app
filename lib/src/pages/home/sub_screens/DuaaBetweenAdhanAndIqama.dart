import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_ar.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

/// this duaa shows the importance of the duaa between adhan and iqamaa
class DuaaBetweenAdhanAndIqamaaScreen extends StatefulWidget {
  const DuaaBetweenAdhanAndIqamaaScreen({
    Key? key,
    this.onDone,
  }) : super(key: key);

  final VoidCallback? onDone;

  @override
  State<DuaaBetweenAdhanAndIqamaaScreen> createState() => _DuaaBetweenAdhanAndIqamaaScreenState();
}

class _DuaaBetweenAdhanAndIqamaaScreenState extends State<DuaaBetweenAdhanAndIqamaaScreen> {
  final arabicTr = AppLocalizationsAr();

  @override
  void initState() {
    final manager = context.read<MosqueManager>();
    final nextIqamaa = manager.nextIqamaaAfter();

    bool skipDuaa = nextIqamaa < Duration(seconds: 30) || nextIqamaa > Duration(minutes: 30);

    if (manager.mosqueConfig!.duaAfterAzanEnabled! && !skipDuaa)
      Future.delayed(30.seconds, widget.onDone);
    else
      Future.delayed(80.milliseconds, widget.onDone);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(R.ASSETS_BACKGROUNDS_ISLAMIC_CONTENT_BACKGROUND_WEBP),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0.5.h),
          child: _DuaaDisplay(
            title: S.of(context).duaaBetweenAdhanAndIqamaaTitle,
            arabicText: arabicTr.duaaBetweenSalahAndAdhan,
            translatedText: S.of(context).duaaBetweenSalahAndAdhan ==
                    arabicTr
                        .duaaBetweenSalahAndAdhan // this if is to avoid the arabic text to be shown in the translated text
                ? ""
                : S.of(context).duaaBetweenSalahAndAdhan,
          ),
        ),
      ),
    );
  }
}

/// Custom widget for displaying duaa content with constrained title
class _DuaaDisplay extends StatelessWidget {
  final String title;
  final String arabicText;
  final String translatedText;

  const _DuaaDisplay({
    super.key,
    required this.title,
    required this.arabicText,
    required this.translatedText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.84),
          child: Text(
            title,
            style: TextStyle(
              shadows: kIqamaCountDownTextShadow,
              color: Colors.white,
              fontSize: 24.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 1.2.h),
        Text(
          arabicText,
          style: TextStyle(
            shadows: kIqamaCountDownTextShadow,
            color: Colors.white,
            fontSize: 22.sp,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.90),
          child: Text(
            translatedText,
            style: TextStyle(
              shadows: kIqamaCountDownTextShadow,
              color: Colors.white,
              fontSize: 22.sp,
              height: 1.2,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ).animate().fade().slide();
  }
}
