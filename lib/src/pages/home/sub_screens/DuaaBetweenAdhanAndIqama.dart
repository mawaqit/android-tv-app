import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_ar.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/pages/home/widgets/HadithScreen.dart';

/// this duaa shows the importance of the duaa between adhan and iqamaa
class DuaaBetweenAdhanAndIqamaaScreen extends StatefulWidget {
  const DuaaBetweenAdhanAndIqamaaScreen({
    Key? key,
    this.onDone,
  }) : super(key: key);

  final VoidCallback? onDone;

  @override
  State<DuaaBetweenAdhanAndIqamaaScreen> createState() =>
      _DuaaBetweenAdhanAndIqamaaScreenState();
}

class _DuaaBetweenAdhanAndIqamaaScreenState
    extends State<DuaaBetweenAdhanAndIqamaaScreen> {
  final arabicTr = AppLocalizationsAr();

  @override
  void initState() {
    Future.delayed(30.seconds, widget.onDone);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HadithWidget(
      title: 'الدعاء لا يرد بين الادان والاقامه',
      arabicText: arabicTr.duaaBetweenSalahAndAdhan,
      translatedText: S.of(context).duaaBetweenSalahAndAdhan,
    );
  }
}
