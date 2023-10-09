import 'package:flutter/widgets.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/SalahItem.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

class JumuaWidget extends StatelessWidget {
  const JumuaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();

    return SalahItemWidget(
      title: S.of(context).jumua,
      time: mosqueManager.jumuaTime ?? "",
      iqama: mosqueManager.times!.jumua2,
      active: mosqueManager.nextIqamaIndex() == 1 && AppDateTime.isFriday && mosqueManager.times?.jumua != null,
      removeBackground: true,
    );
  }
}
