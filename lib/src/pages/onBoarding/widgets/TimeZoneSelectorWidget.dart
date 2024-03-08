import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/l10n.dart';

import '../../../../main.dart';
import '../../../data/countries.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:flutter/services.dart';

const platform = MethodChannel('nativeFunctionsChannel');

class OnBoardingTimeZoneSelector extends StatefulWidget {
  const OnBoardingTimeZoneSelector({Key? key, required this.onSelect})
      : super(key: key);

  final void Function() onSelect;

  @override
  _OnBoardingTimeZoneSelectorState createState() =>
      _OnBoardingTimeZoneSelectorState();
}

class _OnBoardingTimeZoneSelectorState
    extends State<OnBoardingTimeZoneSelector> {
  late List<Country> countriesList;
  late List<String> selectedCountryTimezones;
  TextEditingController searchController = TextEditingController();
  int selectedCountryIndex = -1; // Track selected country index
  int selectedTimezoneIndex = -1; // Track selected timezone index
  bool isViewingTimezones =
      false; // Track whether timezone list is being viewed

  @override
  void initState() {
    super.initState();
    countriesList = Countries.list;
    selectedCountryTimezones = [];
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return FocusScope(
      child: Column(
        children: [
          SizedBox(height: 10),
          Text(
            S.of(context).appTimezone,
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w700,
              color: themeData.brightness == Brightness.dark
                  ? null
                  : themeData.primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            S.of(context).descTimezone,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: themeData.brightness == Brightness.dark
                  ? null
                  : themeData.primaryColor,
            ),
          ),
          SizedBox(height: 20),
          _buildSearchBar(),
          Expanded(
            child: isViewingTimezones
                ? _buildTimezoneList(context)
                : _buildCountryList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            countriesList = Countries.list
                .where((country) =>
                    country.name.toLowerCase().contains(value.toLowerCase()))
                .toList();
          });
        },
        decoration: InputDecoration(
          hintText: S.of(context).searchCountries,
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildCountryList(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: ListView.separated(
        padding: EdgeInsets.only(
          top: 5,
          bottom: 5,
        ),
        itemCount: countriesList.length,
        separatorBuilder: (BuildContext context, int index) =>
            Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          var country = countriesList[index];
          return InkWell(
            onTap: () {
              setState(() {
                selectedCountryIndex = index; // Update selected index
                selectedTimezoneIndex = -1; // Reset timezone index
                selectedCountryTimezones = country.timezones;
                isViewingTimezones = true; // Switch to timezone list view
              });
            },
            child: ListTile(
              title: Text("${country.name}"),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimezoneList(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: WillPopScope(
        onWillPop: () async {
          // Handle back button press
          if (!isViewingTimezones) {
            setState(() {
              isViewingTimezones = false; // Switch back to country list view
            });
            return false; // Prevent back navigation
          }
          return true; // Allow back navigation if not viewing timezones
        },
        child: ListView.separated(
          padding: EdgeInsets.only(
            top: 5,
            bottom: 5,
          ),
          itemCount: selectedCountryTimezones.length,
          separatorBuilder: (BuildContext context, int index) =>
              Divider(height: 1),
          itemBuilder: (BuildContext context, int index) {
            var timezone = selectedCountryTimezones[index];
            var detroit = tz.getLocation(timezone);
            var now = tz.TZDateTime.now(detroit);
            var timeZoneOffset = now.timeZoneOffset;
            return InkWell(
              onTap: () async {
                setState(() {
                  selectedTimezoneIndex = index; // Update selected index
                });
                await _setDeviceTimezone(timezone);
                widget.onSelect?.call();
              },
              child: ListTile(
                title: Text(
                  convertToGMTOffset(timeZoneOffset) + " $timezone",
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _setDeviceTimezone(String timezone) async {
    try {
      await platform.invokeMethod('setDeviceTimezone', {"timezone": timezone});
    } on PlatformException catch (e) {
      logger.e(e);
    }
  }

  String convertToGMTOffset(Duration timeZoneOffset) {
    int totalMinutes = timeZoneOffset.inMinutes;
    String sign = totalMinutes >= 0 ? '+' : '-';
    int hours = (totalMinutes.abs() ~/ 60);
    int minutes = totalMinutes.abs() % 60;

    return 'GMT$sign${_padZero(hours)}:${_padZero(minutes)}';
  }

  String _padZero(int value) => value < 10 ? '0$value' : '$value';
}
