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
/// - Keyboard-aware positioning to prevent dialog from being hidden
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
    Future.delayed(Duration(milliseconds: 100), () {
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
      position: StyledToastPosition.bottom,
      duration: Duration(seconds: 5),
      animation: StyledToastAnimation.scale,
      textStyle: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w100,
        color: Colors.black,
      ),
      backgroundColor: Colors.white10.withOpacity(0.8),
      borderRadius: BorderRadius.circular(15),
      textPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    );
  }

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

  void _cancel() {
    Navigator.of(context).pop(true);
  }

  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is! RawKeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // Handle D-pad navigation
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_passwordFocusNode.hasFocus) {
        FocusScope.of(context).requestFocus(_toggleVisibilityFocusNode);
        return KeyEventResult.handled;
      } else if (_toggleVisibilityFocusNode.hasFocus) {
        FocusScope.of(context).requestFocus(_connectButtonFocusNode);
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_toggleVisibilityFocusNode.hasFocus) {
        FocusScope.of(context).requestFocus(_passwordFocusNode);
        return KeyEventResult.handled;
      } else if (_connectButtonFocusNode.hasFocus) {
        FocusScope.of(context).requestFocus(_toggleVisibilityFocusNode);
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (_passwordFocusNode.hasFocus) {
        FocusScope.of(context).requestFocus(_toggleVisibilityFocusNode);
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (_toggleVisibilityFocusNode.hasFocus) {
        FocusScope.of(context).requestFocus(_passwordFocusNode);
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.select ||
        event.logicalKey == LogicalKeyboardKey.gameButtonA) {
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
    final viewInsets = MediaQuery.of(context).viewInsets;
    final keyboardHeight = viewInsets.bottom;

    // Listen for Wi-Fi connection status changes
    ref.listen(wifiScanNotifierProvider, (previous, next) {
      if (next.hasValue && !next.isRefreshing) {
        if (next.value!.status == Status.connected) {
          _showToast(S.of(context).wifiSuccess);
          widget.onComplete(true);
          Navigator.of(context).pop(false);
        } else if (next.value!.status == Status.error) {
          _showToast(S.of(context).wifiFailure);
          widget.onComplete(false);
          Future.delayed(Duration(milliseconds: 500), () {
            _connectButtonFocusNode.requestFocus();
          });
        }
      }
    });

    return GestureDetector(
      onTap: _cancel,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Focus(
          focusNode: _parentFocusNode,
          onKey: _handleKeyEvent,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.only(
              bottom: keyboardHeight > 0 ? 20 : 0,
            ),
            child: Align(
              alignment: keyboardHeight > 0 ? Alignment.topCenter : Alignment.center,
              child: SingleChildScrollView(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: size.width * 0.95, // Made wider - from 0.9 to 0.95
                    constraints: BoxConstraints(
                      maxWidth: 700, // Increased from 600 to 700
                      minHeight: 300,
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: keyboardHeight > 0 ? 150 : 20,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 10,
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Text(
                              S.of(context).appWifi,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
                              ),
                            ),
                            SizedBox(height: 15),

                            // Network name
                            Row(
                              children: [
                                Icon(Icons.wifi, size: 12.sp),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.ssid,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 25),

                            // Password entry
                            Container(
                              height: 70,
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
                                      style: TextStyle(fontSize: 10.sp),
                                      decoration: InputDecoration(
                                        hintText: S.of(context).wifiPassword,
                                        hintStyle: TextStyle(fontSize: 10.sp),
                                        prefixIcon: Icon(
                                          Icons.lock,
                                          color: _passwordFocusNode.hasFocus ? const Color(0xFF490094) : null,
                                          size: 15.sp,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        fillColor: _passwordFocusNode.hasFocus
                                            ? const Color(0xFF490094).withOpacity(0.05)
                                            : Colors.transparent,
                                        filled: true,
                                      ),
                                      onEditingComplete: () {
                                        FocusScope.of(context).requestFocus(_toggleVisibilityFocusNode);
                                      },
                                      onFieldSubmitted: (_) =>
                                          FocusScope.of(context).requestFocus(_toggleVisibilityFocusNode),
                                    ),
                                  ),

                                  // Password visibility toggle
                                  Focus(
                                    focusNode: _toggleVisibilityFocusNode,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                      child: Container(
                                        width: 60,
                                        height: double.infinity,
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                          color: _toggleVisibilityFocusNode.hasFocus
                                              ? const Color(0xFF490094).withOpacity(0.1)
                                              : Colors.transparent,
                                        ),
                                        child: Icon(
                                          _obscureText ? Icons.visibility : Icons.visibility_off,
                                          color: _toggleVisibilityFocusNode.hasFocus
                                              ? const Color(0xFF490094)
                                              : Colors.grey.shade600,
                                          size: 12.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30),

                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: MawaqitBackIconButton(
                                    icon: Icons.close,
                                    label: S.of(context).cancel,
                                    onPressed: _cancel,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: MawaqitIconButton(
                                    focusNode: _connectButtonFocusNode,
                                    icon: Icons.wifi,
                                    label: S.of(context).connect,
                                    onPressed: _connectToWifi,
                                  ),
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
            ),
          ),
        ),
      ),
    );
  }
}
