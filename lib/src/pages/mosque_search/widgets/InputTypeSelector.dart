import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:mawaqit/src/pages/mosque_search/widgets/chromecast_mosque_input_search.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/MosqueInputId.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/MosqueInputSearch.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/toggle_button_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';

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
  bool _hasSelectedYes = false;
  bool _hasSelectedNo = false;

  @override
  void initState() {
    super.initState();
  }

  void _handleYesSelection() async {
    setState(() {
      _hasSelectedYes = true;
      _hasSelectedNo = false;
    });

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
        Future.delayed(Duration(milliseconds: 300), () {
          if (focus.canRequestFocus) {
            focus.requestFocus();
          }
        });
      },
    );
    ref.read(mosqueInputTypeSelectorProvider.notifier).state = SelectionType.mosqueId;
  }

  void _handleNoSelection() async {
    setState(() {
      _hasSelectedYes = false;
      _hasSelectedNo = true;
    });

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
        Future.delayed(Duration(milliseconds: 300), () {
          if (focus.canRequestFocus) {
            focus.requestFocus();
          }
        });
      },
    );
    ref.read(mosqueInputTypeSelectorProvider.notifier).state = SelectionType.mosqueName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    // Adjust font sizes based on orientation
    final double headerFontSize = isPortrait ? 14.sp : 14.sp;
    final double subtitleFontSize = isPortrait ? 10.sp : 12.sp;
    final double buttonFontSize = isPortrait ? 10.sp : 12.sp;
    final double descriptionFontSize = isPortrait ? 8.sp : 10.sp;

    // Adjust width factor based on orientation
    final double widthFactor = isPortrait ? 0.9 : 0.75;

    return Material(
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header section
            _buildHeader(theme, headerFontSize, subtitleFontSize),
            SizedBox(height: 2.h),

            // Options section
            _buildOptions(
              theme: theme,
              buttonFontSize: buttonFontSize,
              descriptionFontSize: descriptionFontSize,
              isPortrait: isPortrait,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      ThemeData theme,
      double headerFontSize,
      double subtitleFontSize,
      ) {
    return Column(
      children: [
        Text(
          S.of(context).doYouKnowMosqueId,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: headerFontSize,
            height: 1.2,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildOptions({
    required ThemeData theme,
    required double buttonFontSize,
    required double descriptionFontSize,
    required bool isPortrait,
  }) {
    return Column(
      children: [
        // Yes option
        _buildOption(
          theme: theme,
          isSelected: _hasSelectedYes,
          onToggle: _handleYesSelection,
          label: S.of(context).yes,
          description: '',
          buttonFontSize: buttonFontSize,
          descriptionFontSize: descriptionFontSize,
          isPortrait: isPortrait,
          autoFocus: true,
        ),

        SizedBox(height: isPortrait ? 1.5.h : 2.h),

        // No option
        _buildOption(
          theme: theme,
          isSelected: _hasSelectedNo,
          onToggle: _handleNoSelection,
          label: S.of(context).no,
          description: '',
          buttonFontSize: buttonFontSize,
          descriptionFontSize: descriptionFontSize,
          isPortrait: isPortrait,
          autoFocus: false,
        ),
      ],
    );
  }

  Widget _buildOption({
    required ThemeData theme,
    required bool isSelected,
    required VoidCallback onToggle,
    required String label,
    required String description,
    required double buttonFontSize,
    required double descriptionFontSize,
    required bool isPortrait,
    required bool autoFocus,
  }) {
    return Column(
      children: [
        ToggleButtonWidget(
          isSelected: isSelected,
          onPressed: onToggle,
          label: label,
          textStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: buttonFontSize,
            height: 1.2,
          ),
          isPortrait: isPortrait,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isPortrait ? 1.w : 2.w),
          child: Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
              fontSize: descriptionFontSize,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.visible,
            maxLines: 4,
          ),
        ),
      ],
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
