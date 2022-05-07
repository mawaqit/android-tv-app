import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/widgets/mawaqit_circle_button_widget.dart';
import 'package:mawaqit/src/widgets/mosque_info_widget.dart';

class MosqueTileWidget extends StatelessWidget {
  MosqueTileWidget({Key? key, required this.mosque, this.onTap}) : super(key: key);
  final Mosque mosque;

  final void Function()? onTap;
  late final int nextPray = _nextPray();

  bool isFuture(String timeOfDay) {
    final now = TimeOfDay.now();
    final t = TimeOfDay(
      hour: int.parse(timeOfDay.split(":").first),
      minute: int.parse(timeOfDay.split(":").last),
    );

    return t.hour > now.hour || (t.hour == now.hour && t.minute > now.minute);
  }

  int _nextPray() {
    var nextPray = 0;

    if (mosque.times != null) {
      while (true) {
        if (nextPray >= mosque.times!.length) {
          nextPray = 0;
          break;
        }

        if (isFuture(mosque.times![nextPray])) break;

        nextPray++;
      }
    }

    /// change duha to duhr
    if (nextPray == 1) nextPray = 2;

    return nextPray;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    theme = theme.copyWith(
      textTheme: theme.textTheme.apply(
        bodyColor: theme.brightness == Brightness.dark ? Colors.white : theme.primaryColor,
      ),
    );

    return Theme(
      data: theme,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.all(5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MawaqitCircleButton(
                    color: theme.brightness == Brightness.dark ? Colors.white70 : theme.primaryColor,
                    icon: MawaqitIcons.icon_mosque,
                    size: 21,
                    onPressed: onTap,
                  ),
                  Expanded(
                    child: Text(
                      mosque.label ?? mosque.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  MawaqitCircleButton(
                    icon: MawaqitIcons.icon_info1,
                    size: 21,
                    color: theme.brightness == Brightness.dark ? Colors.white70 : theme.primaryColor,
                    onPressed: () {
                      showModalBottomSheet(
                        constraints: BoxConstraints(
                          maxWidth: 600,
                          maxHeight: MediaQuery.of(context).size.height * .8,
                        ),
                        isScrollControlled: true,
                        useRootNavigator: true,
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        elevation: 0,
                        backgroundColor: Theme.of(context).canvasColor,
                        builder: (context) => MosqaueInfoWidget(mosque: mosque),
                      );
                    },
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: S.of(context).jumua,
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextSpan(
                    text: mosque.jumua ?? '',
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 2.0,
              ),
              child: Divider(
                thickness: 1,
                color: Theme.of(context).dividerColor,
              ),
            ),
            if (mosque.times != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < mosque.times!.length; i++)
                    if (i != 1)
                      Container(
                        decoration: BoxDecoration(
                          border: i == nextPray
                              ? Border(
                                  bottom: BorderSide(
                                    color: theme.textTheme.labelLarge!.color!,
                                    width: 2,
                                  ),
                                )
                              : null,
                        ),
                        child: Text(
                          mosque.times![i],
                          style: i == nextPray ? theme.textTheme.labelLarge : theme.textTheme.bodyMedium,
                        ),
                      ),
                ],
              ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
