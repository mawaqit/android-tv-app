import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';

class AfterAdanHadith extends StatefulWidget {
  const AfterAdanHadith({
    Key? key,
    this.duration = const Duration(minutes: 5),
  }) : super(key: key);
  final Duration? duration;

  @override
  State<AfterAdanHadith> createState() => _AfterAdanHadithState();
}

class _AfterAdanHadithState extends State<AfterAdanHadith> {
  final kTitleArabic = 'دعاء ما بعد الأذان';
  final kHadithArabic =
      ' اللَّهمَّ ربَّ هذِهِ الدَّعوةِ التَّامَّةِ ، والصَّلاةِ القائمةِ ، آتِ سيِّدَنا مُحمَّدًا الوسيلةَ والفَضيلةَ ، وابعثهُ مقامًا مَحمودًا الَّذي وعدتَهُ، إنَّكَ لا تخلفُ الميعادَ.';

  @override
  void initState() {
    if (widget.duration != null) {
      Future.delayed(widget.duration!, () {
        if (mounted) Navigator.pop(context);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgrounds/splash_screen_5.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              kTitleArabic,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                color: Colors.lightGreenAccent,
              ),
            ),
            Text(
              kHadithArabic,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
              ),
            ),
            if (Localizations.localeOf(context).languageCode != 'ar') ...[
              Text(
                S.of(context).afterSalahHadithTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  color: Colors.lightGreenAccent,
                ),
              ),
              Text(
                S.of(context).afterSalahHadith,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
