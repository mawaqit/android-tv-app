import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/data/countries.dart';
import 'package:sizer/sizer.dart';
import 'package:scroll_to_index/scroll_to_index.dart'; // Import the package

const platform = MethodChannel('nativeMethodsChannel');

typedef TimezoneSelectedCallback = void Function();

class TimezoneSelectionScreen extends StatefulWidget {
  final Country country;
  final TimezoneSelectedCallback? onTimezoneSelected;
  final FocusNode nextButtonFocusNode;

  const TimezoneSelectionScreen(
      {super.key, required this.country, this.onTimezoneSelected, required this.nextButtonFocusNode});

  @override
  _TimezoneSelectionScreenState createState() => _TimezoneSelectionScreenState();
}

class _TimezoneSelectionScreenState extends State<TimezoneSelectionScreen> {
  late List<String> timezones;
  final FocusNode timezoneListFocusNode = FocusNode();
  int selectedTimezoneIndex = 0;
  late AutoScrollController _scrollController; // Changed to AutoScrollController
  late StreamSubscription<bool> keyboardSubscription;

  @override
  void initState() {
    super.initState();
    timezones = widget.country.timezones;

    // Initialize AutoScrollController instead of standard ScrollController
    _scrollController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical,
    );

    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        FocusScope.of(context).requestFocus(timezoneListFocusNode);
        _selectFirstVisibleItem();
      }
    });

    // Add a post-frame callback to ensure scrolling works after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectFirstVisibleItem();
    });
  }

  @override
  void dispose() {
    timezoneListFocusNode.dispose();
    _scrollController.dispose();
    keyboardSubscription.cancel();
    super.dispose();
  }

  void _handleTimezoneSelect() {
    if (selectedTimezoneIndex >= 0 && selectedTimezoneIndex < timezones.length) {
      _setDeviceTimezoneAsync(timezones[selectedTimezoneIndex]).then((_) {
        // Call the callback to notify that timezone was selected
        if (widget.onTimezoneSelected != null) {
          widget.onTimezoneSelected!();
        }
        // Then focus the next button
        widget.nextButtonFocusNode.requestFocus();
      });
    }
  }

  void _selectFirstVisibleItem() {
    setState(() {
      if (timezones.isNotEmpty) {
        selectedTimezoneIndex = 0;
        _scrollToIndex(selectedTimezoneIndex);
      }
    });

    // Only try to set timezone if the list isn't empty
    if (timezones.isNotEmpty) {
      _setDeviceTimezone(timezones[selectedTimezoneIndex]);
    }
  }

  // New method using scroll_to_index
  Future<void> _scrollToIndex(int index) async {
    await _scrollController.scrollToIndex(
      index,
      preferPosition: AutoScrollPosition.middle, // Center the item
      duration: const Duration(milliseconds: 300),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          if (selectedTimezoneIndex < timezones.length - 1) {
            selectedTimezoneIndex++;
            _scrollToIndex(selectedTimezoneIndex);
          }
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          if (selectedTimezoneIndex > 0) {
            selectedTimezoneIndex--;
            _scrollToIndex(selectedTimezoneIndex);
          }
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
        setState(() {
          final int visibleItems = (_scrollController.position.viewportDimension / 56.0).floor();
          selectedTimezoneIndex = (selectedTimezoneIndex + visibleItems).clamp(0, timezones.length - 1);
          _scrollToIndex(selectedTimezoneIndex);
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {
        // Add page up functionality
        setState(() {
          final int visibleItems = (_scrollController.position.viewportDimension / 56.0).floor();
          selectedTimezoneIndex = (selectedTimezoneIndex - visibleItems).clamp(0, timezones.length - 1);
          _scrollToIndex(selectedTimezoneIndex);
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.select) {
        _handleTimezoneSelect();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Future<void> _setDeviceTimezoneAsync(String timezone) async {
    try {
      await _setDeviceTimezone(timezone);
      // Show success toast
      Fluttertoast.showToast(
        msg: S.of(context).timezoneSuccess,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      debugPrint('Timezone set successfully to: $timezone');
    } catch (e) {
      // Show error toast
      Fluttertoast.showToast(
        msg: S.of(context).timezoneFailure,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      debugPrint('Failed to set timezone: $e');
    }
  }

  Future<void> _setDeviceTimezone(String timezone) async {
    try {
      bool isSuccess = await platform.invokeMethod('setDeviceTimezone', {"timezone": timezone});
      if (!isSuccess) {
        throw Exception('Platform returned false for timezone change');
      }
    } catch (e) {
      debugPrint('Error in platform channel: $e');
      throw Exception('Failed to set timezone: $e');
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
        autofocus: false,
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
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
              ),
            ),
            SizedBox(height: 1.h),
            Divider(
              thickness: 1,
              color: themeData.brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
            SizedBox(height: 1.h),
            Text(
              S.of(context).descTimezone,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                itemCount: timezones.length,
                itemExtent: 56.0,
                // Fixed height for better scrolling
                itemBuilder: (BuildContext context, int index) {
                  var timezone = timezones[index];
                  var location = tz.getLocation(timezone);
                  var now = tz.TZDateTime.now(location);
                  var timeZoneOffset = now.timeZoneOffset;

                  return AutoScrollTag(
                    key: ValueKey(index),
                    controller: _scrollController,
                    index: index,
                    child: ListTile(
                      tileColor: selectedTimezoneIndex == index ? const Color(0xFF490094) : null,
                      contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.3.h),
                      title: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${_convertToGMTOffset(timeZoneOffset)} $timezone',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: selectedTimezoneIndex == index ? Colors.white : null,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedTimezoneIndex = index;
                        });
                        _handleTimezoneSelect();
                      },
                    ),
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
