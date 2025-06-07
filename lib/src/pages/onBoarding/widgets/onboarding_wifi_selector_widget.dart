import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/state_management/kiosk_mode/wifi_scan/wifi_scan_notifier.dart';
import 'package:mawaqit/src/state_management/kiosk_mode/wifi_scan/wifi_scan_state.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'widgets.dart';

const String nativeMethodsChannel = 'nativeMethodsChannel';

class OnBoardingWifiSelector extends ConsumerStatefulWidget {
  const OnBoardingWifiSelector({Key? key, required this.onSelect, this.focusNode}) : super(key: key);

  final void Function() onSelect;
  final FocusNode? focusNode;

  @override
  _OnBoardingWifiSelectorState createState() => _OnBoardingWifiSelectorState();
}

class _OnBoardingWifiSelectorState extends ConsumerState<OnBoardingWifiSelector> {
  // Add a focus node for the scan again button
  final FocusNode _scanAgainButtonFocusNode = FocusNode(debugLabel: 'scan_again_button');
  // Fallback focus node for skip button when widget.focusNode is null
  final FocusNode _fallbackSkipButtonFocusNode = FocusNode(debugLabel: 'fallback_skip_button');

  // Auto scroll controller for WiFi list
  late AutoScrollController _scrollController;
  int _focusedIndex = 0;
  List<FocusNode> _focusNodes = [];
  List<WiFiHunterResultEntry> _filteredAccessPoints = [];

  @override
  void initState() {
    super.initState();
    _scrollController = AutoScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _addLocationPermission();
      await _addFineLocationPermission();
      await ref.read(wifiScanNotifierProvider.notifier).retry();
    });
  }

  @override
  void dispose() {
    _scanAgainButtonFocusNode.dispose();
    _fallbackSkipButtonFocusNode.dispose();
    _scrollController.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _addLocationPermission() async {
    try {
      await platform.invokeMethod('addLocationPermission');
    } on PlatformException catch (e) {
      logger.e("kiosk mode: location permission: error: $e");
    }
  }

  Future<void> _addFineLocationPermission() async {
    try {
      await platform.invokeMethod('grantFineLocationPermission');
    } on PlatformException catch (e) {
      logger.e("kiosk mode: location permission: error: $e");
    }
  }

  void _showToast(String message) {
    showToast(
      message,
      context: context,
      position: StyledToastPosition.bottom,
      duration: Duration(seconds: 4),
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
    );
  }

  void _scrollToIndex(int index) {
    if (_scrollController.hasClients) {
      _scrollController.scrollToIndex(
        index,
        duration: Duration(milliseconds: 200),
      );
    }
  }

  void _changeFocus(int newIndex) {
    // Handle navigation to scan button when going up from the first item
    if (newIndex < 0) {
      setState(() {
        _focusedIndex = -1; // Explicitly set no list item as focused
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Ensure the widget is still in the tree
          _scanAgainButtonFocusNode.requestFocus();
        }
      });
      return;
    }

    // Handle navigation to next/previous buttons when going down from the last item
    if (newIndex >= _focusNodes.length) {
      setState(() {
        _focusedIndex = -1; // Explicitly set no list item as focused
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.focusNode != null && widget.focusNode!.canRequestFocus) {
          widget.focusNode!.requestFocus();
        }
      });
      return;
    }

    setState(() {
      _focusedIndex = newIndex;
      _focusNodes[newIndex].requestFocus();
    });

    _scrollToIndex(newIndex);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final wifiScanState = ref.watch(wifiScanNotifierProvider);
    return Column(
      children: [
        Text(
          S.of(context).appWifi,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
          ),
        ),
        SizedBox(height: 1.h),
        Divider(
          thickness: 0.1.h,
          color: themeData.brightness == Brightness.dark ? Colors.white : Colors.black,
        ),
        SizedBox(height: 1.h),
        Text(
          S.of(context).descWifi,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
            color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: Focus(
                focusNode: _scanAgainButtonFocusNode,
                onKey: (node, event) {
                  if (event is RawKeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                      // Navigate to first WiFi item if available
                      if (_focusNodes.isNotEmpty) {
                        setState(() {
                          _focusedIndex = 0;
                        });
                        _focusNodes[0].requestFocus();
                        _scrollToIndex(0);
                        return KeyEventResult.handled;
                      } else {
                        widget.focusNode!.requestFocus();
                      }
                    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                        event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                      // Navigate to next/previous buttons in onboarding flow
                      if (widget.focusNode != null && widget.focusNode!.canRequestFocus) {
                        widget.focusNode!.requestFocus();
                      }
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: Builder(
                  builder: (context) {
                    final currentFocus = Focus.of(context);
                    final isFocused = currentFocus.hasFocus;
                    return InkWell(
                      onTap: () async => await ref.read(wifiScanNotifierProvider.notifier).retry(),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: isFocused ? Color(0xFF490094) : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isFocused ? Color(0xFF490094) : Colors.grey.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh,
                              size: 16.sp,
                              color: isFocused ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              S.of(context).scanAgain,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: isFocused ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Expanded(
          child: wifiScanState.when(
            data: (state) => state.accessPoints.isEmpty
                ? Text(
                    S.of(context).noScannedResultsFound,
                    style: TextStyle(fontSize: 14.sp),
                  )
                : _buildAccessPointsList(state.accessPoints, state.hasPermission),
            error: (error, s) {
              _showToast('Error fetching access points');

              return Container();
            },
            loading: () => Align(
              child: SizedBox(
                child: CircularProgressIndicator(
                  strokeWidth: 0.5.h,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<WiFiHunterResultEntry> _filterAccessPoints(List<WiFiHunterResultEntry> accessPoints) {
    final seenSSIDs = <String>{};
    return accessPoints.where((ap) {
      if (ap.ssid == "**Hidden SSID**") {
        return true;
      }
      if (!seenSSIDs.contains(ap.ssid)) {
        seenSSIDs.add(ap.ssid);
        return true;
      }
      return false;
    }).toList();
  }

  _buildAccessPointsList(List<WiFiHunterResultEntry> accessPoints, bool _hasPermission) {
    _filteredAccessPoints = _filterAccessPoints(accessPoints);

    // Initialize focus nodes for each item if needed
    if (_focusNodes.length != _filteredAccessPoints.length) {
      // Dispose previous nodes if any
      for (var node in _focusNodes) {
        node.dispose();
      }

      // Create new focus nodes
      _focusNodes = List.generate(
        _filteredAccessPoints.length,
        (index) => FocusNode(debugLabel: 'wifi_item_$index'),
      );

      // Reset focused index
      _focusedIndex = 0;
    }

    // Scroll to the selected WiFi after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_filteredAccessPoints.isNotEmpty) {
        // Only scroll and focus a list item if a valid list item is actually focused
        if (_focusedIndex >= 0 && _focusedIndex < _focusNodes.length) {
          _scrollToIndex(_focusedIndex);
          // Also request focus for the initial selection
          if (_focusNodes.isNotEmpty) {
            // _focusNodes.isNotEmpty is redundant if _focusedIndex < _focusNodes.length and _focusedIndex >=0
            _focusNodes[_focusedIndex].requestFocus();
          }
        }
      }
    });

    return Container(
      padding: EdgeInsets.only(top: 0.5.h),
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(vertical: 0.5.h),
        itemCount: _filteredAccessPoints.length,
        separatorBuilder: (BuildContext context, int index) => Divider(height: 0.1.h).animate().fade(delay: .7.seconds),
        itemBuilder: (context, i) => AutoScrollTag(
          key: ValueKey(i),
          controller: _scrollController,
          index: i,
          child: _AccessPointTile(
            scanAgainFocusNode: _scanAgainButtonFocusNode,
            skipButtonFocusNode: widget.focusNode ?? _fallbackSkipButtonFocusNode,
            onSelect: widget.onSelect,
            accessPoint: _filteredAccessPoints[i],
            hasPermission: _hasPermission,
            focusNode: _focusNodes[i],
            isFocused: _focusedIndex == i,
            index: i,
            onFocusChange: (hasFocus) {
              if (hasFocus && _focusedIndex != i) {
                setState(() {
                  _focusedIndex = i;
                });
                _scrollToIndex(i);
              }
            },
            onKeyEvent: (event, index) {
              if (event is RawKeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                  _changeFocus(index + 1);
                  return KeyEventResult.handled;
                }

                if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                  // If at the first item, focus the scan again button
                  _changeFocus(index - 1);
                  return KeyEventResult.handled;
                }

                if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                    event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                  // Navigate to next/previous buttons in onboarding flow
                  if (widget.focusNode != null && widget.focusNode!.canRequestFocus) {
                    widget.focusNode!.requestFocus();
                  }
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
          ),
        ),
      ),
    );
  }
}

class _AccessPointTile extends ConsumerStatefulWidget {
  final WiFiHunterResultEntry accessPoint;
  final FocusNode skipButtonFocusNode;
  final FocusNode scanAgainFocusNode;
  final bool hasPermission;
  final void Function() onSelect;
  final FocusNode focusNode;
  final bool isFocused;
  final int index;
  final void Function(bool) onFocusChange;
  final KeyEventResult Function(RawKeyEvent, int) onKeyEvent;

  _AccessPointTile({
    Key? key,
    required this.skipButtonFocusNode,
    required this.scanAgainFocusNode,
    required this.onSelect,
    required this.accessPoint,
    required this.hasPermission,
    required this.focusNode,
    required this.isFocused,
    required this.index,
    required this.onFocusChange,
    required this.onKeyEvent,
  }) : super(key: key);

  @override
  _AccessPointTileState createState() => _AccessPointTileState();
}

class _AccessPointTileState extends ConsumerState<_AccessPointTile> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode;
  }

  @override
  void dispose() {
    // Don't dispose _focusNode here since it's managed by the parent
    super.dispose();
  }

  void _showToast(String message) {
    showToast(
      message,
      context: context,
      position: StyledToastPosition.bottom,
      duration: Duration(seconds: 4),
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.accessPoint.ssid.isNotEmpty ? widget.accessPoint.ssid : S.of(context).noSSID;
    final signalIcon = widget.accessPoint.level >= -80 ? Icons.signal_wifi_4_bar : Icons.signal_wifi_0_bar;

    ref.listen(wifiScanNotifierProvider, (previous, next) {
      if (next.hasValue && !next.isRefreshing && next.value!.status == Status.connected) {
        _showToast(S.of(context).wifiSuccess);
      }
      if (next.value!.status == Status.error) {
        _showToast(S.of(context).wifiFailure);
      }
    });

    void handleSelection() {
      // Always use the TV-friendly Wi-Fi password screen
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => TvWifiPasswordScreen(
            ssid: widget.accessPoint.ssid,
            capabilities: widget.accessPoint.capabilities,
            returnFocusNode: fp.Option.of(_focusNode),
            onComplete: (success) {
              // Handle completion
              if (success) {
                widget.onSelect();
              }

              // We don't need to request focus here - the TvWifiPasswordScreen
              // will ensure focus is handled properly when returning
            },
          ),
        ),
      )
          .then((wasCancelled) {
        Future.delayed(
          Duration(milliseconds: 500),
          () {
            if (wasCancelled == true) {
              widget.scanAgainFocusNode.requestFocus();
            } else {
              _focusNode.requestFocus();
            }
          },
        );
      });
    }

    return Material(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.2.h),
        child: Ink(
          decoration: BoxDecoration(
            color: widget.isFocused ? Theme.of(context).focusColor : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Focus(
            focusNode: _focusNode,
            onFocusChange: widget.onFocusChange,
            onKey: (node, event) {
              // Pass the event to the parent's onKeyEvent handler FIRST
              final result = widget.onKeyEvent(event, widget.index);
              if (result == KeyEventResult.handled) {
                return result;
              }

              // Then handle select/enter locally
              if (event is RawKeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
                  handleSelection();
                  return KeyEventResult.handled;
                }
                // Left/Right arrow keys are now handled by the onKeyEvent passed from the parent
              }
              return KeyEventResult.ignored;
            },
            child: Builder(
              builder: (context) {
                return InkWell(
                  onTap: handleSelection,
                  borderRadius: BorderRadius.circular(10),
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                    textColor: widget.isFocused ? Colors.white : null,
                    leading: Icon(signalIcon, size: 16.sp),
                    title: Text(
                      title,
                      style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
