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

import 'onboarding_timezone_selector.dart';

const String nativeMethodsChannel = 'nativeMethodsChannel';

class OnBoardingWifiSelector extends ConsumerStatefulWidget {
  const OnBoardingWifiSelector({Key? key, required this.onSelect, this.focusNode}) : super(key: key);

  final void Function() onSelect;
  final FocusNode? focusNode;

  @override
  _OnBoardingWifiSelectorState createState() => _OnBoardingWifiSelectorState();
}

class _OnBoardingWifiSelectorState extends ConsumerState<OnBoardingWifiSelector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _addLocationPermission();
      await _addFineLocationPermission();
      await ref.read(wifiScanNotifierProvider.notifier).retry();
    });
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

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final wifiScanState = ref.watch(wifiScanNotifierProvider);
    final FocusNode accessPointsFocusNode = FocusNode();

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
            ElevatedButton.icon(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h)),
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.focused)) {
                      return const Color(0xFF490094); // Focus color
                    }
                    return null; // Use the default color
                  },
                ),
                foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.focused)) {
                      return Colors.white; // Text and icon color when focused
                    }
                    return null; // Use the default color
                  },
                ),
              ),
              icon: Icon(Icons.refresh, size: 16.sp),
              label: Text(
                S.of(context).scanAgain,
                style: TextStyle(fontSize: 10.sp),
              ),
              onPressed: () async => await ref.read(wifiScanNotifierProvider.notifier).retry(),
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
                : _buildAccessPointsList(state.accessPoints, state.hasPermission, accessPointsFocusNode),
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

  _buildAccessPointsList(List<WiFiHunterResultEntry> accessPoints, bool _hasPermission, FocusNode node) {
    final filteredAccessPoints = _filterAccessPoints(accessPoints);

    return Container(
      padding: EdgeInsets.only(top: 0.5.h),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 0.5.h),
        itemCount: filteredAccessPoints.length,
        itemBuilder: (context, i) => _AccessPointTile(
          skipButtonFocusNode: widget.focusNode ?? FocusNode(),
          focusNode: node,
          onSelect: widget.onSelect,
          accessPoint: filteredAccessPoints[i],
          hasPermission: _hasPermission,
        ),
      ),
    );
  }
}

class _AccessPointTile extends ConsumerStatefulWidget {
  final WiFiHunterResultEntry accessPoint;
  final FocusNode skipButtonFocusNode;
  final bool hasPermission;
  final void Function() onSelect;
  final FocusNode focusNode;

  _AccessPointTile({
    Key? key,
    required this.focusNode,
    required this.skipButtonFocusNode,
    required this.onSelect,
    required this.accessPoint,
    required this.hasPermission,
  }) : super(key: key);

  @override
  _AccessPointTileState createState() => _AccessPointTileState();
}

class _AccessPointTileState extends ConsumerState<_AccessPointTile> {
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

    KeyEventResult _handleKeyEvent(FocusNode focusNode, RawKeyEvent event) {
      if (event is RawKeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          FocusScope.of(context).requestFocus(widget.skipButtonFocusNode);

          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    }

    return Focus(
      focusNode: widget.focusNode,
      onKey: (node, event) => _handleKeyEvent(node, event),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        leading: Icon(signalIcon, size: 16.sp),
        title: Text(title, style: TextStyle(fontSize: 12.sp)),
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
        onTap: () {
          // Save current focus state for restoration after route transition
          final currentFocus = widget.focusNode;

          // Only apply web-specific fixes on web platform
          if (kIsWeb) {
            // Ensure focus node stays active even during navigation
            WidgetsBinding.instance.addPostFrameCallback((_) {
              FocusManager.instance.primaryFocus?.unfocus();
              // Keep a reference to return focus here after navigation
            });
          }

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WifiPasswordPage(
                ssid: widget.accessPoint.ssid,
                capabilities: widget.accessPoint.capabilities,
                onConnect: (password) async {
                  // Prevent focus loss on web platform
                  if (kIsWeb) {
                    // Save current focus for restoration
                    final currentFocus = FocusScope.of(context).focusedChild;

                    // Schedule focus restoration after the operation
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (currentFocus != null && currentFocus.canRequestFocus) {
                        FocusScope.of(context).requestFocus(currentFocus);
                      } else {
                        // Fallback to widget's focusNode if available
                        if (widget.focusNode.canRequestFocus) {
                          FocusScope.of(context).requestFocus(widget.focusNode);
                        }
                      }
                    });
                  }

                  await ref.read(wifiScanNotifierProvider.notifier).connectToWifi(
                        widget.accessPoint.ssid,
                        widget.accessPoint.capabilities,
                        password,
                      );
                  Navigator.of(context).pop();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class WifiPasswordPage extends StatefulWidget {
  final String ssid;
  final String capabilities;
  final Function(String) onConnect;

  const WifiPasswordPage({
    Key? key,
    required this.ssid,
    required this.capabilities,
    required this.onConnect,
  }) : super(key: key);

  @override
  _WifiPasswordPageState createState() => _WifiPasswordPageState();
}

class _WifiPasswordPageState extends State<WifiPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  bool _showPassword = false;
  final FocusNode _parentFocusNode = FocusNode(debugLabel: 'wifi_password_parent');
  final FocusNode connectButtonFocusNode = FocusNode();
  final FocusNode passwordInputFocusNode = FocusNode();
  final FocusNode cancelButtonFocusNode = FocusNode();
  Color _buttonColor = Colors.white; // Default color
  Color _textColor = Colors.black; // Default color

  @override
  void initState() {
    super.initState();

    passwordInputFocusNode.addListener(_onSearchFocusChange);
    connectButtonFocusNode.addListener(_onConnectButtonFocusChange);
    cancelButtonFocusNode.addListener(_onCancelButtonFocusChange);

    // Auto-focus on password input when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      passwordInputFocusNode.requestFocus();
    });
  }

  void _onConnectButtonFocusChange() {
    setState(() {
      _buttonColor = connectButtonFocusNode.hasFocus ? const Color(0xFF490094) : Colors.white;
      _textColor = connectButtonFocusNode.hasFocus ? Colors.white : Colors.black;
    });
  }

  void _onCancelButtonFocusChange() {
    setState(() {
      // Apply focus styling to cancel button if needed
    });
  }

  void _onSearchFocusChange() {
    if (!passwordInputFocusNode.hasFocus) {
      // Only auto-switch focus in certain cases
    }
  }

  // Handle key events for the entire dialog
  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is! RawKeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.tab || event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (passwordInputFocusNode.hasFocus) {
        FocusScope.of(context).requestFocus(connectButtonFocusNode);
        return KeyEventResult.handled;
      } else if (connectButtonFocusNode.hasFocus) {
        FocusScope.of(context).requestFocus(cancelButtonFocusNode);
        return KeyEventResult.handled;
      } else if (cancelButtonFocusNode.hasFocus) {
        FocusScope.of(context).requestFocus(passwordInputFocusNode);
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (passwordInputFocusNode.hasFocus) {
        FocusScope.of(context).requestFocus(cancelButtonFocusNode);
        return KeyEventResult.handled;
      } else if (connectButtonFocusNode.hasFocus) {
        FocusScope.of(context).requestFocus(passwordInputFocusNode);
        return KeyEventResult.handled;
      } else if (cancelButtonFocusNode.hasFocus) {
        FocusScope.of(context).requestFocus(connectButtonFocusNode);
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (cancelButtonFocusNode.hasFocus) {
        FocusScope.of(context).requestFocus(connectButtonFocusNode);
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (connectButtonFocusNode.hasFocus) {
        FocusScope.of(context).requestFocus(cancelButtonFocusNode);
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    passwordController.dispose();
    passwordInputFocusNode.dispose();
    connectButtonFocusNode.dispose();
    cancelButtonFocusNode.dispose();
    _parentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Focus(
        focusNode: _parentFocusNode,
        onKey: _handleKeyEvent,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with network name
                    Text(
                      S.of(context).appWifi,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.ssid,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 24),

                    // Password input field
                    TextFormField(
                      controller: passwordController,
                      focusNode: passwordInputFocusNode,
                      obscureText: !_showPassword,
                      // Support both physical and virtual keyboards
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: S.of(context).wifiPassword,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Password visibility toggle
                            IconButton(
                              icon: Icon(
                                _showPassword ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                            ),
                            // Virtual keyboard button for TV/remote devices
                            IconButton(
                              icon: Icon(Icons.keyboard),
                              onPressed: () {
                                // Show on-screen keyboard or toggle focus
                                passwordInputFocusNode.requestFocus();
                              },
                            ),
                          ],
                        ),
                      ),
                      onFieldSubmitted: (_) {
                        // When user presses enter after typing password, attempt connection
                        widget.onConnect(passwordController.text);
                      },
                    ),
                    SizedBox(height: 24),

                    // Buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          focusNode: cancelButtonFocusNode,
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                              if (states.contains(MaterialState.focused)) {
                                return Colors.grey.shade300;
                              }
                              return null;
                            }),
                          ),
                          onPressed: () {
                            // Prevent focus loss on web platform
                            if (kIsWeb) {
                              // Ensure parent focus node stays focused
                              FocusScope.of(context).requestFocus(_parentFocusNode);
                            }
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            S.of(context).close,
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          focusNode: connectButtonFocusNode,
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                              if (states.contains(MaterialState.focused)) {
                                return const Color(0xFF490094);
                              }
                              return null;
                            }),
                            foregroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                              if (states.contains(MaterialState.focused)) {
                                return Colors.white;
                              }
                              return null;
                            }),
                          ),
                          onPressed: () {
                            // Prevent focus loss on web platform
                            if (kIsWeb) {
                              // Ensure parent focus node stays focused
                              FocusScope.of(context).requestFocus(_parentFocusNode);
                            }
                            widget.onConnect(passwordController.text);
                          },
                          child: Text(
                            S.of(context).connect,
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
