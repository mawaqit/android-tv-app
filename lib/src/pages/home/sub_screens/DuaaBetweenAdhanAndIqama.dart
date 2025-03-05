import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_ar.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/widgets/display_text_widget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

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
    final manager = context.read<MosqueManager>();
    final nextIqamaa = manager.nextIqamaaAfter();

    bool skipDuaa = nextIqamaa < Duration(seconds: 30) ||
        nextIqamaa > Duration(minutes: 30);

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
          image: AssetImage(R.ASSETS_BACKGROUNDS_BACKGROUND_ADHKAR_JPG),
          fit: BoxFit.cover,
        ),
      ),
      child: DisplayTextWidget(
        title: 'الدعاء لا يرد بين الأذان والإقامة',
        arabicText: arabicTr.duaaBetweenSalahAndAdhan,
        translatedText: S.of(context).duaaBetweenSalahAndAdhan,
      ),
    );
  }
}
