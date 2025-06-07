import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mawaqit/src/helpers/TimeShiftManager.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:flutter/services.dart';
import '../../../../i18n/l10n.dart';
import '../../../../main.dart';
import '../../../data/countries.dart';

const platform = MethodChannel('nativeMethodsChannel');

class OnBoardingTimeZoneSelector extends StatefulWidget {
  final void Function()? onSelect;
  final FocusNode? focusNode;
  const OnBoardingTimeZoneSelector({Key? key, this.onSelect, this.focusNode}) : super(key: key);

  @override
  _OnBoardingTimeZoneSelectorState createState() => _OnBoardingTimeZoneSelectorState();
}

class _OnBoardingTimeZoneSelectorState extends State<OnBoardingTimeZoneSelector> {
  late List<Country> countriesList;
  late List<String> selectedCountryTimezones;
  final TextEditingController searchController = TextEditingController();
  final FocusNode countryListFocusNode = FocusNode();
  final FocusNode timezoneListFocusNode = FocusNode();
  final FocusNode searchfocusNode = FocusNode();
  int selectedCountryIndex = -1;
  int selectedTimezoneIndex = -1;
  bool isViewingTimezones = false;
  final TimeShiftManager _timeManager = TimeShiftManager();
  late ScrollController _countryScrollController;
  late ScrollController _timezoneScrollController;
  late StreamSubscription<bool> keyboardSubscription;

  Future<void> addLocationPermission() async {
    try {
      await platform.invokeMethod('addLocationPermission');
    } on PlatformException catch (e) {
      logger.e("kiosk mode: location permission: error: $e");
    }
  }

  Future<void> addFineLocationPermission() async {
    try {
      await platform.invokeMethod('grantFineLocationPermission');
    } on PlatformException catch (e) {
      logger.e("kiosk mode: location permission: error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await addLocationPermission();
      await addFineLocationPermission();
    });
    countriesList = Countries.list;
    selectedCountryTimezones = [];
    _countryScrollController = ScrollController();
    _timezoneScrollController = ScrollController();
    var keyboardVisibilityController = KeyboardVisibilityController();

    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        FocusScope.of(context).requestFocus(countryListFocusNode);
        _selectFirstVisibleItem();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    countryListFocusNode.dispose();
    timezoneListFocusNode.dispose();
    _countryScrollController.dispose();
    _timezoneScrollController.dispose();
    searchfocusNode.dispose();

    super.dispose();
  }

  void _scrollToSelectedItem(ScrollController controller, int selectedIndex, double itemHeight,
      {double topPadding = 0}) {
    if (selectedIndex >= 0) {
      final listViewHeight = controller.position.viewportDimension;
      final scrollPosition = (selectedIndex * itemHeight) - topPadding;

      // Calculate the maximum scroll extent
      final maxScrollExtent = controller.position.maxScrollExtent;

      // Ensure the scroll position is within bounds
      final targetScrollPosition = scrollPosition.clamp(0.0, maxScrollExtent);

      // If the item is in the bottom half of the list view, scroll a bit further to center it
      final centeringOffset = (listViewHeight / 2) - (itemHeight / 2);
      final centeredScrollPosition = (targetScrollPosition - centeringOffset).clamp(0.0, maxScrollExtent);

      controller.animateTo(
        centeredScrollPosition,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _filterItems(String query) {
    setState(() {
      countriesList =
          Countries.list.where((country) => country.name.toLowerCase().contains(query.toLowerCase())).toList();
      selectedCountryIndex = -1; // Reset the selected index
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          if (isViewingTimezones) {
            if (selectedTimezoneIndex < selectedCountryTimezones.length - 1) {
              selectedTimezoneIndex++;
              _scrollToSelectedItem(_timezoneScrollController, selectedTimezoneIndex, 56.0, topPadding: 16.0);
            }
          } else {
            if (selectedCountryIndex < countriesList.length - 1) {
              selectedCountryIndex++;
              _scrollToSelectedItem(_countryScrollController, selectedCountryIndex, 56.0, topPadding: 16.0);
            }
          }
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          if (isViewingTimezones) {
            if (selectedTimezoneIndex > 0) {
              selectedTimezoneIndex--;
              _scrollToSelectedItem(_timezoneScrollController, selectedTimezoneIndex, 56.0, topPadding: 16.0);
            } else if (selectedTimezoneIndex == 0) {
              // Move focus back to country list
              isViewingTimezones = false;
              FocusScope.of(context).requestFocus(countryListFocusNode);
            }
          } else {
            if (selectedCountryIndex > 0) {
              selectedCountryIndex--;
              _scrollToSelectedItem(_countryScrollController, selectedCountryIndex, 56.0, topPadding: 16.0);
            } else if (selectedCountryIndex == 0) {
              // Move focus back to search input
              FocusScope.of(context).requestFocus(searchfocusNode);
              selectedCountryIndex = -1;
            }
          }
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.select) {
        _handleEnterKey();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        setState(() {
          FocusScope.of(context).unfocus();
          FocusScope.of(context).requestFocus(widget.focusNode);
        });
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _handleEnterKey() {
    if (isViewingTimezones) {
      if (selectedTimezoneIndex >= 0 && selectedTimezoneIndex < selectedCountryTimezones.length) {
        _setDeviceTimezoneAsync(selectedCountryTimezones[selectedTimezoneIndex]);
      }
    } else {
      if (selectedCountryIndex >= 0 && selectedCountryIndex < countriesList.length) {
        var country = countriesList[selectedCountryIndex];
        setState(() {
          selectedCountryTimezones = country.timezones;
          isViewingTimezones = true;
          selectedTimezoneIndex = 0; // Set to 0 to select the first item
          FocusScope.of(context).requestFocus(timezoneListFocusNode);
        });
        // Scroll to the first item
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToSelectedItem(_timezoneScrollController, selectedTimezoneIndex, 56.0, topPadding: 16.0);
        });
      }
    }
  }

  Future<void> _setDeviceTimezoneAsync(String timezone) async {
    try {
      await _setDeviceTimezone(timezone);
      widget.onSelect?.call();
    } catch (e) {
      print('Error setting timezone: $e');
    }
  }

  void _selectFirstVisibleItem() {
    setState(() {
      if (isViewingTimezones) {
        if (selectedCountryTimezones.isNotEmpty) {
          selectedTimezoneIndex = 0;
          _scrollToSelectedItem(_timezoneScrollController, selectedTimezoneIndex, 56.0, topPadding: 16.0);
        }
      } else {
        if (countriesList.isNotEmpty && selectedCountryIndex == -1) {
          selectedCountryIndex = 0;
          _scrollToSelectedItem(_countryScrollController, selectedCountryIndex, 56.0, topPadding: 16.0);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: FocusScope(
        node: FocusScopeNode(),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              S.of(context).appTimezone,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.w700,
                color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Divider(
              thickness: 1,
              color: themeData.brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 10),
            Text(
              S.of(context).descTimezone,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                autofocus: false,
                focusNode: searchfocusNode,
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(countryListFocusNode);
                  _selectFirstVisibleItem();
                },
                controller: searchController,
                onChanged: _filterItems,
                decoration: InputDecoration(
                  hintText: S.of(context).searchCountries,
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Focus(
                focusNode: isViewingTimezones ? timezoneListFocusNode : countryListFocusNode,
                onFocusChange: (hasFocus) {
                  if (hasFocus) {
                    _selectFirstVisibleItem();
                  }
                },
                onKey: (node, event) => _handleKeyEvent(node, event),
                child: isViewingTimezones ? _buildTimezoneList(context) : _buildCountryList(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryList(BuildContext context) {
    return ListView.builder(
      controller: _countryScrollController,
      itemCount: countriesList.length,
      padding: EdgeInsets.only(top: 16),
      itemBuilder: (BuildContext context, int index) {
        var country = countriesList[index];
        return ListTile(
          tileColor: selectedCountryIndex == index ? const Color(0xFF490094) : null,
          title: Text(country.name),
          onTap: () {
            setState(() {
              selectedCountryIndex = index;
              selectedTimezoneIndex = -1;
              selectedCountryTimezones = country.timezones;
              isViewingTimezones = true;
              FocusScope.of(context).requestFocus(timezoneListFocusNode);
            });
          },
        );
      },
    );
  }

  Widget _buildTimezoneList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 16),
      controller: _timezoneScrollController,
      itemCount: selectedCountryTimezones.length,
      itemBuilder: (BuildContext context, int index) {
        var timezone = selectedCountryTimezones[index];
        var location = tz.getLocation(timezone);
        var now = tz.TZDateTime.now(location);
        var timeZoneOffset = now.timeZoneOffset;
        return ListTile(
          tileColor: selectedTimezoneIndex == index ? const Color(0xFF490094) : null,
          title: Text('${_convertToGMTOffset(timeZoneOffset)} $timezone'),
          onTap: () async {
            setState(() {
              selectedTimezoneIndex = index;
            });
            await _setDeviceTimezone(timezone);
            widget.onSelect?.call();
          },
        );
      },
    );
  }

  Future<void> _setDeviceTimezone(String timezone) async {
    try {
      bool isSuccess = await platform.invokeMethod('setDeviceTimezone', {"timezone": timezone});
      if (isSuccess) {
        _showToast(S.of(context).timezoneSuccess);
      } else {
        _showToast(S.of(context).timezoneFailure);
      }
    } on PlatformException catch (e) {
      logger.e(e);
      _showToast(S.of(context).timezoneFailure);
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  String _convertToGMTOffset(Duration timeZoneOffset) {
    int totalMinutes = timeZoneOffset.inMinutes;
    String sign = totalMinutes >= 0 ? '+' : '-';
    int hours = totalMinutes.abs() ~/ 60;
    int minutes = totalMinutes.abs() % 60;
    return 'GMT$sign${_padZero(hours)}:${_padZero(minutes)}';
  }

  String _padZero(int value) => value < 10 ? '0$value' : '$value';
}
