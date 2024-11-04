import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:mawaqit/src/widgets/iqama_time_widget.dart';
import 'package:mawaqit/src/widgets/time_widget.dart';
import 'package:provider/provider.dart';

/// this is used to show salah item on home screen in vertical mode
class HorizontalSalahItem extends StatelessWidget {
  const HorizontalSalahItem({
    Key? key,
    required this.time,
    this.title,
    this.iqama,
    this.active = false,
    this.removeBackground = false,
    this.withDivider = true,
    this.showIqama = true,
    this.isIqamaMoreImportant = false,
    this.margin,
  }) : super(key: key);

  final String? title;
  final String time;
  final String? iqama;

  /// show divider only when both time and iqama exists
  final bool withDivider;
  final bool active;
  final bool removeBackground;
  final bool showIqama;

  /// make iqama larger than the time
  final bool isIqamaMoreImportant;

  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    double titleFont = 3.5.vwr;
    double bigFont = 4.5.vwr;
    double smallFont = 3.5.vwr;

    final mosqueProvider = context.watch<MosqueManager>();
    final mosqueConfig = mosqueProvider.mosqueConfig;
    final iqamaEnabled = mosqueConfig?.iqamaEnabled == true;

    final is24period = mosqueConfig?.timeDisplayFormat != "12";

    // Determine if the item should be highlighted
    final shouldHighlight = active && (!iqamaEnabled || (iqama?.isNotEmpty ?? false));

    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 5.vw),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.vw),
        color: shouldHighlight
            ? mosqueProvider.getColorTheme().withOpacity(.5)
            : removeBackground
                ? null
                : Colors.black.withOpacity(.5),
      ),
      padding: EdgeInsets.symmetric(vertical: 1.vh, horizontal: 1.vw),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (title != null && title!.trim().isNotEmpty)
            Expanded(
              child: Center(
                child: Text(
                  maxLines: 1,
                  title ?? "",
                  style: TextStyle(
                    height: 1,
                    fontSize: titleFont,
                    shadows: kHomeTextShadow,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: TimeWidget.fromString(
                show24hFormat: is24period,
                time: time,
                style: TextStyle(
                  fontSize: isIqamaMoreImportant ? smallFont : bigFont,
                  fontWeight: FontWeight.w700,
                  shadows: kHomeTextShadow,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          iqama == null
              ? Container()
              : Expanded(
                  child: Center(
                    child: IqamaTimeWidget(
                      time: iqama!,
                      show24hFormat: is24period,
                      style: TextStyle(
                        fontSize: isIqamaMoreImportant ? bigFont : smallFont,
                        fontWeight: FontWeight.w700,
                        shadows: kHomeTextShadow,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
