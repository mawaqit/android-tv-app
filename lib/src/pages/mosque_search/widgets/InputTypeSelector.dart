import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:mawaqit/src/pages/mosque_search/widgets/chromecast_mosque_input_search.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/MosqueInputId.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/MosqueInputSearch.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../i18n/l10n.dart';
import '../../../../main.dart';
import '../../../helpers/Api.dart';
import 'chromecast_mosque_input_id.dart';

class InputTypeSelector extends StatefulWidget {
  const InputTypeSelector({
    required this.nextButtonFocusNode,
    super.key,
    this.onDone,
  });

  final void Function()? onDone;
  final fp.Option<FocusNode> nextButtonFocusNode;

  @override
  _InputTypeSelectorState createState() => _InputTypeSelectorState();
}

class _InputTypeSelectorState extends State<InputTypeSelector> {
  String? _deviceModel;

  @override
  void initState() {
    super.initState();
    _fetchDeviceModel();
  }

  Future<void> _fetchDeviceModel() async {
    try {
      final userData = await Api.prepareUserData();
      if (userData != null) {
        setState(() {
          _deviceModel = userData.$2['model'];
        });
      }
    } catch (e, stackTrace) {
      logger.e('Error fetching user data: $e', stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              S.of(context).doYouKnowMosqueId,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: isLight ? theme.primaryColor : Colors.white,
              ),
            ),
            SizedBox(height: 10),
            OutlinedButton(
              autofocus: true,
              onPressed: () {
                widget.nextButtonFocusNode.match(() => {}, (focus) {
                  focus.requestFocus();
                  return;
                });

                Navigator.push(
                  context,
                  PageTransition(
                    child: _deviceModel!.contains("Chromecast")
                        ? ChromeCastMosqueInputId(onDone: widget.onDone)
                        : MosqueInputId(onDone: widget.onDone),
                    type: PageTransitionType.fade,
                    alignment: Alignment.center,
                  ),
                );
              },
              child: Text(S.current.yes),
            ),
            OutlinedButton(
              onPressed: () {
                widget.nextButtonFocusNode.match(() => {}, (focus) {
                  focus.requestFocus();
                  return;
                });
                Navigator.push(
                  context,
                  PageTransition(
                    child: _deviceModel!.contains("Chromecast")
                        ? ChromeCastMosqueInputSearch(
                            onDone: widget.onDone,
                          )
                        : MosqueInputSearch(onDone: widget.onDone),
                    type: PageTransitionType.fade,
                    alignment: Alignment.center,
                  ),
                );
              },
              child: Text(S.current.no),
            ),
          ],
        ),
      ),
    );
  }
}
