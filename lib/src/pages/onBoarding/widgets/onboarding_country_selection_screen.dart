import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/pages/onBoarding/OnBoardingScreen.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/onboarding_time_zone_selection_screen.dart';
import '../../../data/countries.dart';
import '../../../../i18n/l10n.dart';

class CountrySelectionScreen extends ConsumerStatefulWidget {
  final void Function(Country country)? onSelect;
  final FocusNode? focusNode;
  final FocusNode? nextButtonFocusNode;

  const CountrySelectionScreen({
    Key? key,
    this.onSelect,
    this.focusNode,
    this.nextButtonFocusNode,
  }) : super(key: key);

  @override
  _CountrySelectionScreenState createState() => _CountrySelectionScreenState();
}

class _CountrySelectionScreenState extends ConsumerState<CountrySelectionScreen> {
  late List<Country> countriesList;
  final TextEditingController searchController = TextEditingController();
  final FocusNode countryListFocusNode = FocusNode();
  final FocusNode searchfocusNode = FocusNode();
  int selectedCountryIndex = -1;
  late ScrollController _countryScrollController;
  late StreamSubscription<bool> keyboardSubscription;

  @override
  void initState() {
    super.initState();
    countriesList = Countries.list;
    _countryScrollController = ScrollController();
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
    _countryScrollController.dispose();
    searchfocusNode.dispose();
    keyboardSubscription.cancel();
    super.dispose();
  }

  void _scrollToSelectedItem(ScrollController controller, int selectedIndex, double itemHeight,
      {double topPadding = 0}) {
    if (selectedIndex >= 0) {
      final listViewHeight = controller.position.viewportDimension;
      final scrollPosition = (selectedIndex * itemHeight) - topPadding;
      final maxScrollExtent = controller.position.maxScrollExtent;
      final targetScrollPosition = scrollPosition.clamp(0.0, maxScrollExtent);
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
      selectedCountryIndex = -1;
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          if (selectedCountryIndex < countriesList.length - 1) {
            selectedCountryIndex++;
            _scrollToSelectedItem(_countryScrollController, selectedCountryIndex, 56.0, topPadding: 16.0);
          }
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        // print('up: ${ref.watch(nextNodeProvider).hasFocus}');
        setState(() {
          if (selectedCountryIndex > 0) {
            selectedCountryIndex--;
            _scrollToSelectedItem(_countryScrollController, selectedCountryIndex, 56.0, topPadding: 16.0);
          } else if (selectedCountryIndex == 0) {
            FocusScope.of(context).requestFocus(searchfocusNode);
            selectedCountryIndex = -1;
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
    if (selectedCountryIndex >= 0 && selectedCountryIndex < countriesList.length) {
      var country = countriesList[selectedCountryIndex];
      widget.onSelect?.call(country);
      if(widget.nextButtonFocusNode != null) {
        widget.nextButtonFocusNode?.requestFocus();
      }
    }
  }

  void _selectFirstVisibleItem() {
    setState(() {
      if (countriesList.isNotEmpty && selectedCountryIndex == -1) {
        selectedCountryIndex = 0;
        _scrollToSelectedItem(_countryScrollController, selectedCountryIndex, 56.0, topPadding: 16.0);
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
      child: Scaffold(
        body: FocusScope(
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
                  autofocus: true,
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
                  focusNode: countryListFocusNode,
                  onFocusChange: (hasFocus) {
                    if (hasFocus) {
                      _selectFirstVisibleItem();
                    }
                  },
                  onKey: (node, event) => _handleKeyEvent(node, event),
                  child: ListView.builder(
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
                            widget.onSelect?.call(country);
                            if(widget.nextButtonFocusNode != null) {
                              widget.nextButtonFocusNode?.requestFocus();
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
