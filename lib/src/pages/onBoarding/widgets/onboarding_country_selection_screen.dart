import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/data/countries.dart';
import 'package:mawaqit/src/state_management/on_boarding/on_boarding.dart';
import 'package:sizer/sizer.dart';
import '../../../../main.dart';

class CountrySelectionScreen extends ConsumerStatefulWidget {
  final void Function(Country country)? onSelect;
  final FocusNode? nextButtonFocusNode;

  const CountrySelectionScreen({
    Key? key,
    this.onSelect,
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
  late AutoScrollController _autoScrollController;
  late StreamSubscription<bool> keyboardSubscription;

  // Scroll configurations
  final double _itemHeight = 56.0;
  final Duration _scrollDuration = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    countriesList = Countries.list;

    // Initialize AutoScrollController
    _autoScrollController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical,
    );

    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        Future.delayed(Duration(milliseconds: 100), () {
          if (countryListFocusNode.canRequestFocus && mounted) {
            FocusScope.of(context).requestFocus(countryListFocusNode);
            _selectFirstVisibleItem();
          }
        });
      }
    });

    // Load previously selected country and navigate to it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndNavigateToSelectedCountry();
    });
  }

  /// Load previously selected country and navigate to it in the list
  Future<void> _loadAndNavigateToSelectedCountry() async {
    try {
      final savedCountry = await ref.read(onBoardingProvider.notifier).loadSelectedCountry();
      if (savedCountry != null && mounted) {
        final countryIndex = countriesList.indexWhere(
          (country) => country.isoCode == savedCountry.isoCode,
        );

        if (countryIndex != -1) {
          setState(() {
            selectedCountryIndex = countryIndex;
          });

          widget.onSelect?.call(countriesList[countryIndex]);

          await _scrollToIndex(countryIndex);
          if (countryListFocusNode.canRequestFocus) {
            countryListFocusNode.requestFocus();
          }
        }
      }
    } catch (e, stackTrace) {
      logger.e('Error loading and processing selected country: $e', stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    countryListFocusNode.dispose();
    _autoScrollController.dispose();
    searchfocusNode.dispose();
    keyboardSubscription.cancel();
    super.dispose();
  }

  // Method to scroll to an indexed item
  Future<void> _scrollToIndex(int index) async {
    if (index < 0 || index >= countriesList.length) return;

    await _autoScrollController.scrollToIndex(
      index,
      preferPosition: AutoScrollPosition.middle,
      duration: _scrollDuration,
    );
  }

  void _filterItems(String query) {
    setState(() {
      countriesList =
          Countries.list.where((country) => country.name.toLowerCase().contains(query.toLowerCase())).toList();
      selectedCountryIndex = -1;

      if (countriesList.isEmpty && widget.nextButtonFocusNode != null) {
        Future.delayed(Duration(milliseconds: 100), () {
          if (widget.nextButtonFocusNode!.canRequestFocus && mounted) {
            widget.nextButtonFocusNode!.requestFocus();
          }
        });
      }
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          if (selectedCountryIndex < countriesList.length - 1) {
            selectedCountryIndex++;
            _scrollToIndex(selectedCountryIndex);
          }
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          if (selectedCountryIndex > 0) {
            selectedCountryIndex--;
            _scrollToIndex(selectedCountryIndex);
          } else if (selectedCountryIndex == 0) {
            // Check if the focus node can request focus before attempting to focus it
            if (searchfocusNode.canRequestFocus && mounted) {
              FocusScope.of(context).requestFocus(searchfocusNode);
            }
            selectedCountryIndex = -1;
          }
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.select) {
        _handleEnterKey();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (widget.nextButtonFocusNode != null && widget.nextButtonFocusNode!.canRequestFocus) {
          widget.nextButtonFocusNode!.requestFocus();
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
        // Page down: move several items down at once
        setState(() {
          final int visibleItems = (_autoScrollController.position.viewportDimension / _itemHeight).floor();
          final int newIndex = (selectedCountryIndex + visibleItems).clamp(0, countriesList.length - 1);
          selectedCountryIndex = newIndex;
          _scrollToIndex(selectedCountryIndex);
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {
        // Page up: move several items up at once
        setState(() {
          final int visibleItems = (_autoScrollController.position.viewportDimension / _itemHeight).floor();
          final int newIndex = (selectedCountryIndex - visibleItems).clamp(0, countriesList.length - 1);
          selectedCountryIndex = newIndex;
          _scrollToIndex(selectedCountryIndex);
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.home) {
        // Home: go to the first item
        setState(() {
          selectedCountryIndex = 0;
          _scrollToIndex(selectedCountryIndex);
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.end) {
        // End: go to the last item
        setState(() {
          selectedCountryIndex = countriesList.length - 1;
          _scrollToIndex(selectedCountryIndex);
        });
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _handleEnterKey() {
    if (selectedCountryIndex >= 0 && selectedCountryIndex < countriesList.length) {
      var country = countriesList[selectedCountryIndex];
      _selectCountry(country);
    }
  }

  /// Handle country selection - save to state and call onSelect callback
  void _selectCountry(Country country) async {
    try {
      widget.onSelect?.call(country);
      // Focus the next button
      if (widget.nextButtonFocusNode != null && widget.nextButtonFocusNode!.canRequestFocus) {
        widget.nextButtonFocusNode!.requestFocus();
      }
    } catch (e, stackTrace) {
      // Handle error - still call onSelect even if something goes wrong
      logger.e('Error during country selection or focusing next button: $e', stackTrace: stackTrace);
      widget.onSelect?.call(country);
      if (widget.nextButtonFocusNode != null && widget.nextButtonFocusNode!.canRequestFocus) {
        widget.nextButtonFocusNode!.requestFocus();
      }
    }
  }

  void _selectFirstVisibleItem() {
    setState(() {
      if (countriesList.isNotEmpty && selectedCountryIndex == -1) {
        selectedCountryIndex = 0;
        _scrollToIndex(selectedCountryIndex);
      } else if (countriesList.isEmpty && widget.nextButtonFocusNode != null) {
        widget.nextButtonFocusNode!.requestFocus();
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
                fontSize: 10.sp,
                color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
              ),
            ),
            SizedBox(height: 1.h),
            TextField(
              // Removed autofocus
              focusNode: searchfocusNode,
              onSubmitted: (_) {
                if (countriesList.isEmpty) {
                  // Focus next button if the filtered list is empty
                  if (widget.nextButtonFocusNode != null && widget.nextButtonFocusNode!.canRequestFocus && mounted) {
                    widget.nextButtonFocusNode!.requestFocus();
                  }
                } else if (countryListFocusNode.canRequestFocus && mounted) {
                  FocusScope.of(context).requestFocus(countryListFocusNode);
                  _selectFirstVisibleItem();
                }
              },
              controller: searchController,
              onChanged: _filterItems,
              style: TextStyle(fontSize: 10.sp),
              decoration: InputDecoration(
                hintText: S.of(context).searchCountries,
                hintStyle: TextStyle(fontSize: 10.sp),
                prefixIcon: Icon(Icons.search, size: 5.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
            ),
            SizedBox(height: 1.h),
            Expanded(
              child: Focus(
                focusNode: countryListFocusNode,
                autofocus: false,
                // Remove autofocus from the country list
                onFocusChange: (hasFocus) {
                  if (hasFocus) {
                    _selectFirstVisibleItem();
                  }
                },
                onKey: (node, event) => _handleKeyEvent(node, event),
                child: countriesList.isEmpty
                    ? Center(
                        child: Text(
                          S.of(context).mosqueNoResults,
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      )
                    : ListView.builder(
                        controller: _autoScrollController,
                        itemCount: countriesList.length,
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                        itemBuilder: (BuildContext context, int index) {
                          var country = countriesList[index];
                          return AutoScrollTag(
                            key: ValueKey(index),
                            controller: _autoScrollController,
                            index: index,
                            child: ListTile(
                              tileColor: selectedCountryIndex == index ? const Color(0xFF490094) : null,
                              contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                              title: Text(
                                country.name,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: selectedCountryIndex == index ? Colors.white : null,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  selectedCountryIndex = index;
                                });
                                _selectCountry(country);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
