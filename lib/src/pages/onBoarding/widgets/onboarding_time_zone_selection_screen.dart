import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/data/countries.dart';
import 'package:sizer/sizer.dart';

const platform = MethodChannel('nativeMethodsChannel');

typedef TimezoneSelectedCallback = void Function();

class TimezoneSelectionScreen extends StatefulWidget {
  final Country country;
  final TimezoneSelectedCallback? onTimezoneSelected;
  final FocusNode nextButtonFocusNode;

  const TimezoneSelectionScreen(
      {super.key,
      required this.country,
      this.onTimezoneSelected,
      required this.nextButtonFocusNode});

  @override
  _TimezoneSelectionScreenState createState() =>
      _TimezoneSelectionScreenState();
}

class _TimezoneSelectionScreenState extends State<TimezoneSelectionScreen> {
  late List<String> timezones;
  final FocusNode timezoneListFocusNode = FocusNode();
  int selectedTimezoneIndex = 0;
  late ScrollController _timezoneScrollController;
  late StreamSubscription<bool> keyboardSubscription;

  @override
  void initState() {
    super.initState();
    timezones = widget.country.timezones;
    _timezoneScrollController = ScrollController();

    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        FocusScope.of(context).requestFocus(timezoneListFocusNode);
        _selectFirstVisibleItem();
      }
    });

    _handleTimezoneSelect();
  }

  @override
  void dispose() {
    timezoneListFocusNode.dispose();
    _timezoneScrollController.dispose();
    keyboardSubscription.cancel();
    super.dispose();
  }

  void _handleTimezoneSelect() {
    if (selectedTimezoneIndex >= 0 &&
        selectedTimezoneIndex < timezones.length) {
      _setDeviceTimezoneAsync(timezones[selectedTimezoneIndex]).then((_) {
        widget.nextButtonFocusNode.requestFocus();
      });
    }
  }

  void _selectFirstVisibleItem() {
    setState(() {
      if (timezones.isNotEmpty) {
        selectedTimezoneIndex = 0;
        _scrollToSelectedItem(
            _timezoneScrollController, selectedTimezoneIndex, 56.0,
            topPadding: 16.0);
      }
    });
  }

  void _scrollToSelectedItem(
      ScrollController controller, int selectedIndex, double itemHeight,
      {double topPadding = 0}) {
    if (selectedIndex >= 0) {
      final listViewHeight = controller.position.viewportDimension;
      final scrollPosition = (selectedIndex * itemHeight) - topPadding;
      final maxScrollExtent = controller.position.maxScrollExtent;
      final targetScrollPosition = scrollPosition.clamp(0.0, maxScrollExtent);
      final centeringOffset = (listViewHeight / 2) - (itemHeight / 2);
      final centeredScrollPosition =
          (targetScrollPosition - centeringOffset).clamp(0.0, maxScrollExtent);

      controller.animateTo(
        centeredScrollPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Basic key handling for navigation in the timezone list.
  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          if (selectedTimezoneIndex < timezones.length - 1) {
            selectedTimezoneIndex++;
            _scrollToSelectedItem(
                _timezoneScrollController, selectedTimezoneIndex, 56.0,
                topPadding: 16.0);
          }
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          if (selectedTimezoneIndex > 0) {
            selectedTimezoneIndex--;
            _scrollToSelectedItem(
                _timezoneScrollController, selectedTimezoneIndex, 56.0,
                topPadding: 16.0);
          }
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        _handleTimezoneSelect();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Future<void> _setDeviceTimezoneAsync(String timezone) async {
    try {
      await _setDeviceTimezone(timezone);
      Fluttertoast.showToast(
        msg: S.of(context).timezoneSuccess,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: S.of(context).timezoneFailure,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _setDeviceTimezone(String timezone) async {
    bool isSuccess = await platform
        .invokeMethod('setDeviceTimezone', {"timezone": timezone});
    if (!isSuccess) {
      throw Exception('Failed to set timezone');
    }
  }

  String _convertToGMTOffset(Duration timeZoneOffset) {
    int totalMinutes = timeZoneOffset.inMinutes;
    String sign = totalMinutes >= 0 ? '+' : '-';
    int hours = totalMinutes.abs() ~/ 60;
    int minutes = totalMinutes.abs() % 60;
    return 'GMT$sign${_padZero(hours)}:${_padZero(minutes)}';
  }

  String _padZero(int value) => value < 10 ? '0$value' : '$value';

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: Focus(
        focusNode: timezoneListFocusNode,
        onFocusChange: (hasFocus) {
          if (hasFocus) {
            _selectFirstVisibleItem();
          }
        },
        onKey: (node, event) => _handleKeyEvent(node, event),
        child: Column(
          children: [
            SizedBox(height: 1.h),
            Text(
              S.of(context).appTimezone,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: themeData.brightness == Brightness.dark
                    ? null
                    : themeData.primaryColor,
              ),
            ),
            SizedBox(height: 1.h),
            Divider(
              thickness: 1,
              color: themeData.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            SizedBox(height: 1.h),
            Text(
              S.of(context).descTimezone,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: themeData.brightness == Brightness.dark
                    ? null
                    : themeData.primaryColor,
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _timezoneScrollController,
                padding: EdgeInsets.only(top: 2.h),
                itemCount: timezones.length,
                itemBuilder: (BuildContext context, int index) {
                  var timezone = timezones[index];
                  var location = tz.getLocation(timezone);
                  var now = tz.TZDateTime.now(location);
                  var timeZoneOffset = now.timeZoneOffset;
                  return ListTile(
                    tileColor: selectedTimezoneIndex == index
                        ? const Color(0xFF490094)
                        : null,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                    title: Text(
                      '${_convertToGMTOffset(timeZoneOffset)} $timezone',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    onTap: () {
                      setState(() {
                        selectedTimezoneIndex = index;
                      });
                      _handleTimezoneSelect();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
