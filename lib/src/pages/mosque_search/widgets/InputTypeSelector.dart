import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:mawaqit/src/pages/mosque_search/widgets/chromecast_mosque_input_search.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/MosqueInputId.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/MosqueInputSearch.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../i18n/l10n.dart';
import '../../../../main.dart';
import '../../../helpers/Api.dart';
import '../../../state_management/on_boarding/input_selection_provider.dart';
import 'chromecast_mosque_input_id.dart';

class InputTypeSelector extends ConsumerStatefulWidget {
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

class _InputTypeSelectorState extends ConsumerState<InputTypeSelector> {
  String? _deviceModel;

  @override
  void initState() {
    super.initState();
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
              onPressed: () async {
                final deviceModel = await _fetchDeviceModel() ?? '';
                final isChromeCast = deviceModel.contains('chromecast');
                widget.nextButtonFocusNode.fold(
                  () {
                    if (isChromeCast) {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          alignment: Alignment.center,
                          child: ChromeCastMosqueInputId(
                            onDone: widget.onDone,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          alignment: Alignment.center,
                          child: MosqueInputId(
                            onDone: widget.onDone,
                          ),
                        ),
                      );
                    }
                  },
                  (focus) {
                    focus.requestFocus();
                  },
                );
                ref.read(mosqueInputTypeSelectorProvider.notifier).state = SelectionType.mosqueId;
              },
              child: Text(S.current.yes),
            ),
            OutlinedButton(
              onPressed: () async {
                final deviceModel = await _fetchDeviceModel() ?? '';
                final isChromeCast = deviceModel.contains('chromecast');
                widget.nextButtonFocusNode.fold(
                  () {
                    if (isChromeCast) {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          alignment: Alignment.center,
                          child: ChromeCastMosqueInputId(
                            onDone: widget.onDone,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          alignment: Alignment.center,
                          child: MosqueInputSearch(
                            onDone: widget.onDone,
                          ),
                        ),
                      );
                    }
                  },
                  (focus) {
                    focus.requestFocus();
                  },
                );
                ref.read(mosqueInputTypeSelectorProvider.notifier).state = SelectionType.mosqueName;
              },
              child: Text(S.current.no),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _fetchDeviceModel() async {
    try {
      final userData = await Api.prepareUserData();
      if (userData != null) {
        return userData.$2['model'];
      }
      return null;
    } catch (e, stackTrace) {
      logger.e('Error fetching user data: $e', stackTrace: stackTrace);
      return null;
    }
  }
}

enum SelectionType {
  mosqueId,
  mosqueName,
}

final mosqueInputTypeSelectorProvider = StateProvider<SelectionType>((ref) {
  return SelectionType.mosqueId;
});
