import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/state_management/kiosk_mode/wifi_scan/wifi_scan_notifier.dart';
import 'package:mawaqit/src/state_management/kiosk_mode/wifi_scan/wifi_scan_state.dart';
import 'package:mawaqit/src/widgets/mawaqit_icon_button.dart';
import 'package:mawaqit/src/widgets/mawaqit_back_icon_button.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/foundation.dart';

/// A dedicated TV-friendly Wi-Fi password entry screen for Android TV
/// - Optimized for D-pad/remote navigation
/// - Enhanced focus handling
/// - Visual focus indicators
/// - Support for both remote navigation and keyboard input
class TvWifiPasswordScreen extends ConsumerStatefulWidget {
  final String ssid;
  final String capabilities;
  final fp.Option<FocusNode> returnFocusNode;
  final void Function(bool success) onComplete;

  const TvWifiPasswordScreen({
    Key? key,
    required this.ssid,
    required this.capabilities,
    required this.onComplete,
    this.returnFocusNode = const fp.None(),
  }) : super(key: key);

  @override
  _TvWifiPasswordScreenState createState() => _TvWifiPasswordScreenState();
}

class _TvWifiPasswordScreenState extends ConsumerState<TvWifiPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode(debugLabel: 'password_input');
  final FocusNode _connectButtonFocusNode = FocusNode(debugLabel: 'connect_button');
  final FocusNode _toggleVisibilityFocusNode = FocusNode(debugLabel: 'toggle_visibility');
  final FocusNode _parentFocusNode = FocusNode(debugLabel: 'parent_container');

  bool _obscureText = true;
  FocusNode? _lastFocusedNode;

  @override
  void initState() {
    super.initState();

    // Focus listeners for visual updates
    _passwordFocusNode.addListener(_onFocusChange);
    _connectButtonFocusNode.addListener(_onFocusChange);
    _toggleVisibilityFocusNode.addListener(_onFocusChange);

    // Set initial focus to password field after a short delay
    // This ensures the widget is fully built before setting focus

    // Use a timeout to prevent indefinite focus issues
    final timeout = Future.delayed(Duration(seconds: 2), () {
      // No focus was requested within timeout, nothing to do
    });

    Future.delayed(Duration(milliseconds: 100), () {
      // Cancel timeout since we're handling it
      timeout.ignore();

      if (mounted && _passwordFocusNode.canRequestFocus) {
        _passwordFocusNode.requestFocus();
      }
    });
  }

  void _onFocusChange() {
    // Track the last focused node for navigation
    if (_passwordFocusNode.hasFocus) {
      _lastFocusedNode = _passwordFocusNode;
    } else if (_connectButtonFocusNode.hasFocus) {
      _lastFocusedNode = _connectButtonFocusNode;
    } else if (_toggleVisibilityFocusNode.hasFocus) {
      _lastFocusedNode = _toggleVisibilityFocusNode;
    }

    // Trigger rebuild for focus visual changes
    if (mounted) {
      setState(() {});
    }
  }

  void _showToast(String message) {
    showToast(
      message,
      context: context,
      position: StyledToastPosition.center,
      duration: Duration(seconds: 3),
      animation: StyledToastAnimation.scale,
    );
  }

  // Connect to the Wi-Fi network with the entered password
  void _connectToWifi() {
    if (_passwordController.text.isEmpty) {
      _showToast(S.of(context).wifiFailure);
      return;
    }

    ref.read(wifiScanNotifierProvider.notifier).connectToWifi(
          widget.ssid,
          widget.capabilities,
          _passwordController.text,
        );
  }

  // Cancel and return to previous screen
  void _cancel() {
    Navigator.of(context).pop();
    // Focus will be restored by the calling widget after navigation completes
  }

  // Handle keyboard navigation and shortcuts
  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is! RawKeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // Handle D-pad navigation
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_passwordFocusNode.hasFocus) {
        // From password field to toggle visibility
        FocusScope.of(context).requestFocus(_toggleVisibilityFocusNode);
        return KeyEventResult.handled;
      } else if (_toggleVisibilityFocusNode.hasFocus) {
        // From toggle visibility to connect button
        FocusScope.of(context).requestFocus(_connectButtonFocusNode);
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_toggleVisibilityFocusNode.hasFocus) {
        // From toggle visibility to password field
        FocusScope.of(context).requestFocus(_passwordFocusNode);
        return KeyEventResult.handled;
      } else if (_connectButtonFocusNode.hasFocus) {
        // From connect button to toggle visibility
        FocusScope.of(context).requestFocus(_toggleVisibilityFocusNode);
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (_passwordFocusNode.hasFocus) {
        // From password field to visibility toggle
        FocusScope.of(context).requestFocus(_toggleVisibilityFocusNode);
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (_toggleVisibilityFocusNode.hasFocus) {
        // From visibility toggle to password field
        FocusScope.of(context).requestFocus(_passwordFocusNode);
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.select ||
        event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      // Handle various "OK" buttons from remote controls
      if (_toggleVisibilityFocusNode.hasFocus) {
        setState(() {
          _obscureText = !_obscureText;
        });
        return KeyEventResult.handled;
      } else if (_connectButtonFocusNode.hasFocus) {
        _connectToWifi();
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.escape || event.logicalKey == LogicalKeyboardKey.gameButtonB) {
      _cancel();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _connectButtonFocusNode.dispose();
    _toggleVisibilityFocusNode.dispose();
    _parentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    // Listen for Wi-Fi connection status changes
    ref.listen(wifiScanNotifierProvider, (previous, next) {
      if (next.hasValue && !next.isRefreshing) {
        if (next.value!.status == Status.connected) {
          _showToast(S.of(context).wifiSuccess);
          widget.onComplete(true);
          // Just navigate back, focus will be handled by the calling widget
          Navigator.of(context).pop();
        } else if (next.value!.status == Status.error) {
          _showToast(S.of(context).wifiFailure);
          widget.onComplete(false);

          Future.delayed(
            Duration(milliseconds: 500),
            () {
              _connectButtonFocusNode.requestFocus();
            },
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Focus(
        focusNode: _parentFocusNode,
        onKey: _handleKeyEvent,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? size.width * 0.9 : 600,
              maxHeight: isSmallScreen ? size.height * 0.8 : 400,
            ),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 10,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      S.of(context).appWifi,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18.sp : 20.sp,
                        fontWeight: FontWeight.bold,
                        color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 6 : 10),

                    // Network name
                    Row(
                      children: [
                        Icon(Icons.wifi, size: isSmallScreen ? 16.sp : 18.sp),
                        SizedBox(width: isSmallScreen ? 6 : 10),
                        Expanded(
                          child: Text(
                            widget.ssid,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14.sp : 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),

                    // Password entry with focus highlighting
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _passwordFocusNode.hasFocus ? const Color(0xFF490094) : Colors.grey.shade400,
                          width: _passwordFocusNode.hasFocus ? 2.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              autofocus: true,
                              obscureText: _obscureText,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.done,
                              style: TextStyle(fontSize: isSmallScreen ? 14.sp : 16.sp),
                              decoration: InputDecoration(
                                hintText: S.of(context).wifiPassword,
                                prefixIcon: Icon(Icons.lock,
                                    color: _passwordFocusNode.hasFocus ? const Color(0xFF490094) : null),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                fillColor: _passwordFocusNode.hasFocus
                                    ? const Color(0xFF490094).withOpacity(0.05)
                                    : Colors.transparent,
                                filled: true,
                              ),
                              onEditingComplete: () {
                                FocusScope.of(context).requestFocus(_toggleVisibilityFocusNode);
                              },
                              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_toggleVisibilityFocusNode),
                            ),
                          ),

                          // Password visibility toggle with focus highlighting
                          Focus(
                            focusNode: _toggleVisibilityFocusNode,
                            child: Container(
                              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                              child: Icon(
                                _obscureText ? Icons.remove_red_eye : Icons.visibility_off,
                                color: _toggleVisibilityFocusNode.hasFocus
                                    ? const Color(0xFF490094)
                                    : Colors.grey.shade100,
                                size: isSmallScreen ? 18.sp : 20.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 30),

                    // Action buttons with Mawaqit button components
                    Row(
                      children: [
                        Expanded(child: Container()),
                        // Negative action button (start side - left in LTR, right in RTL)
                        MawaqitBackIconButton(
                          icon: Icons.close,
                          label: S.of(context).cancel,
                          onPressed: _cancel,
                        ),

                        // Positive action button (end side - right in LTR, left in RTL)
                        MawaqitIconButton(
                          focusNode: _connectButtonFocusNode,
                          icon: Icons.wifi,
                          label: S.of(context).connect,
                          onPressed: _connectToWifi,
                        ),
                      ],
                    )
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
