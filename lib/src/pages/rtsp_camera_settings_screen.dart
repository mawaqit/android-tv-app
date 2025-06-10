import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/domain/error/rtsp_expceptions.dart';
import 'package:mawaqit/src/state_management/livestream_viewer/live_stream_notifier_v2.dart';
import 'package:mawaqit/src/state_management/livestream_viewer/live_stream_state_v2.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:sizer/sizer.dart';
import 'package:mawaqit/src/widgets/safe_youtube_player.dart';

class RTSPCameraSettingsScreen extends ConsumerStatefulWidget {
  const RTSPCameraSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RTSPCameraSettingsScreen> createState() => _RTSPCameraSettingsScreenState();
}

class _RTSPCameraSettingsScreenState extends ConsumerState<RTSPCameraSettingsScreen> {
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _saveButtonFocusNode = FocusNode();
  final FocusNode _replaceWorkflowWithStreamButtonFocusNode = FocusNode();
  late StreamSubscription<bool> keyboardSubscription;
  
  // Local state to track unsaved changes
  bool? _localReplaceWorkflow;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    dev.log('🖥️ [RTSP_SCREEN] Initializing RTSP Camera Settings Screen');
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        dev.log('⌨️ [RTSP_SCREEN] Keyboard hidden, focusing save button');
        FocusScope.of(context).requestFocus(_replaceWorkflowWithStreamButtonFocusNode);
      }
    });
  }

  @override
  void dispose() {
    dev.log('🧹 [RTSP_SCREEN] Disposing RTSP Camera Settings Screen');
    _urlController.dispose();
    _saveButtonFocusNode.dispose();
    _replaceWorkflowWithStreamButtonFocusNode.dispose();
    keyboardSubscription.cancel();
    super.dispose();
  }

  void _updateUrlController(LiveStreamState state) {
    if (state.streamUrl != null && _urlController.text != state.streamUrl) {
      dev.log('📝 [RTSP_SCREEN] Updating URL controller with: ${state.streamUrl}');
      _urlController.text = state.streamUrl!;
    }
    
    // Initialize local state from provider state
    if (_localReplaceWorkflow == null) {
      _localReplaceWorkflow = state.replaceWorkflow;
      _hasUnsavedChanges = false;
    }
  }

  /// Handle saving stream with proper user feedback
  Future<void> _handleSaveStream(LiveStreamState state) async {
    dev.log('💾 [RTSP_SCREEN] Save button pressed with URL: ${_urlController.text}');
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final enteredUrl = _urlController.text.trim();
    
    // Clear any existing snackbars
    scaffoldMessenger.clearSnackBars();
    
    // Validate input
    if (enteredUrl.isEmpty) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(S.of(context).enterRtspUrl),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    
    // Show processing indicator
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(S.of(context).validatingStream),
          ],
        ),
        duration: const Duration(seconds: 30), // Long duration, will be cleared when done
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blue,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    try {
      // Check if URL actually changed
      final hasUrlChanged = enteredUrl != state.streamUrl;
      final hasWorkflowChanged = _localReplaceWorkflow != null && 
                                 _localReplaceWorkflow != state.replaceWorkflow;
      
      if (hasUrlChanged) {
        dev.log('🔄 [RTSP_SCREEN] URL changed, updating stream');
        
        // Update the stream
        await ref.read(liveStreamProviderV2.notifier).updateStream(enteredUrl);
        
        // Wait a bit for the state to settle
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Check the final state to show appropriate feedback
        final newState = ref.read(liveStreamProviderV2).value;
        scaffoldMessenger.clearSnackBars();
        
        if (newState != null && newState.isReadyToPlay) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(S.of(context).validRtspUrl),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
      
      // Save workflow replacement setting if changed
      if (hasWorkflowChanged) {
        dev.log('🔄 [RTSP_SCREEN] Workflow replacement setting changed, saving: $_localReplaceWorkflow');
        await ref.read(liveStreamProviderV2.notifier).toggleReplaceWorkflow(_localReplaceWorkflow!);
      }
      
      // If nothing changed but user pressed save, still show feedback
      if (!hasUrlChanged && !hasWorkflowChanged) {
        scaffoldMessenger.clearSnackBars();
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Text('Settings saved'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      
      // Clear unsaved changes flag
      setState(() {
        _hasUnsavedChanges = false;
      });
    } catch (e) {
      dev.log('🚨 [RTSP_SCREEN] Error saving stream: $e');
      scaffoldMessenger.clearSnackBars();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error saving stream: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(liveStreamProviderV2);
    ref.listen(liveStreamProviderV2, (previous, next) {
      if (next.hasValue) {
        _updateUrlController(next.value!);
      }
      // Only show error messages, not success messages on every state change
      if (previous != next && next.hasValue && next.value!.hasError) {
        final state = next.value!;
        dev.log('❌ [RTSP_SCREEN] Stream error detected: ${state.errorMessage}');
        
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.errorMessage ?? S.of(context).invalidRtspUrl,
              style: const TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    });

    return asyncState.when(
      data: (state) {
        dev.log('🏗️ [RTSP_SCREEN] Building screen with state: ${state.isEnabled ? "Enabled" : "Disabled"}');
        return Scaffold(
          appBar: state.isEnabled
              ? AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                )
              : null,
          body: SafeArea(
            child: Stack(
              children: [
                if (!state.isEnabled)
                  ScreenWithAnimationWidget(
                    animation: "settings",
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildSettingsContent(state),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).dividerColor),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: _buildVideoPreview(state),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildSettingsContent(state),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
      loading: () {
        dev.log('⏳ [RTSP_SCREEN] Loading state');
        return Scaffold(
          body: _buildLoadingOverlay(),
        );
      },
      error: (error, stackTrace) {
        dev.log('🚨 [RTSP_SCREEN] Error state: $error');
        if (error is RTSPCameraException) {
          return _buildErrorScreen(error);
        } else {
          return _buildErrorScreen(RTSPStreamUpdateException(error.toString()));
        }
      },
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  S.of(context).validatingStream,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(RTSPCameraException error) {
    String errorMessage = '';

    errorMessage = S.of(context).somethingWentWrong;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(liveStreamProviderV2);
              },
              child: Text(S.of(context).tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview(LiveStreamState state) {
    dev.log('🎥 [RTSP_SCREEN] Building video preview for type: ${state.streamType}');
    
    // Don't render widget if stream is connecting (prevents disposed controller issues)
    if (state.isConnecting) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Connecting to stream...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }
    
    // Only use streamWidget if it exists and state is ready
    if (state.streamWidget != null && state.isReadyToPlay) {
      // Wrap in a key to force widget rebuilding when stream changes
      // Include stream status to force rebuild when connecting/active states change
      return KeyedSubtree(
        key: ValueKey('${state.streamType}_${state.streamUrl}_${state.streamStatus}'),
        child: state.streamWidget!,
      );
    }
    
    // Fallback placeholder
    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.videocam_off,
          size: 48,
          color: Colors.white54,
        ),
      ),
    );
  }

  /// Build stream status indicator widget
  Widget _buildStreamStatusIndicator(LiveStreamState state) {
    IconData icon;
    Color color;
    String text;

    if (state.isConnecting) {
      icon = Icons.sync;
      color = Colors.orange;
      text = 'Connecting...';
    } else if (state.isReadyToPlay) {
      icon = Icons.check_circle;
      color = Colors.green;
      text = 'Stream Ready';
    } else if (state.hasError) {
      icon = Icons.error;
      color = Colors.red;
      text = state.errorMessage ?? 'Error';
    } else if (state.streamUrl != null && state.streamUrl!.isNotEmpty) {
      icon = Icons.info;
      color = Colors.blue;
      text = 'Stream Configured';
    } else {
      icon = Icons.help_outline;
      color = Colors.grey;
      text = 'No URL Configured';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          if (state.isConnecting)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            )
          else
            Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent(LiveStreamState state) {
    dev.log('⚙️ [RTSP_SCREEN] Building settings content');
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          S.of(context).rtspCameraSettings,
          style: Theme.of(context).textTheme.titleMedium?.apply(fontSizeFactor: 2),
          textAlign: TextAlign.center,
        ),
        const Divider(indent: 50, endIndent: 50),
        const SizedBox(height: 10),
        Text(
          S.of(context).rtspCameraSettingScreenDesc,
          style: Theme.of(context).textTheme.bodySmall?.apply(fontSizeFactor: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        SwitchListTile(
          title: Row(
            children: [
              Text(S.of(context).enableRtspCamera),
              if (state.isConnecting) ...[
                const SizedBox(width: 12),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
              ],
            ],
          ),
          value: state.isEnabled,
          autofocus: true,
          onChanged: state.isConnecting 
            ? null // Disable during connection
            : (value) {
                dev.log('🔌 [RTSP_SCREEN] Toggling RTSP enabled state: $value');
                ref.read(liveStreamProviderV2.notifier).toggleEnabled(value);
              },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          focusNode: _replaceWorkflowWithStreamButtonFocusNode,
          title: Text(S.of(context).replaceWorkflowWithStream),
          subtitle: Text(S.of(context).replaceAppWorkflowWithCameraStream),
          value: _localReplaceWorkflow ?? state.replaceWorkflow,
          onChanged: (state.isEnabled && !state.isConnecting)
              ? (value) {
                  dev.log('🔄 [RTSP_SCREEN] Local workflow replacement changed: $value');
                  setState(() {
                    _localReplaceWorkflow = value;
                    _hasUnsavedChanges = (_localReplaceWorkflow != state.replaceWorkflow) || 
                                        (_urlController.text != state.streamUrl);
                  });
                }
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        if (state.isEnabled) ...[
          const SizedBox(height: 20),
          Text(
            S.of(context).addRtspUrl,
            style: Theme.of(context).textTheme.bodyLarge?.apply(fontSizeFactor: 1.2),
            textAlign: TextAlign.center,
          ),
          const Divider(indent: 50, endIndent: 50),
          const SizedBox(height: 20),
          TextField(
            controller: _urlController,
            enabled: !state.isConnecting, // Disable during connection
            onChanged: (value) {
              setState(() {
                _hasUnsavedChanges = (value.trim() != state.streamUrl) || 
                                    (_localReplaceWorkflow != state.replaceWorkflow);
              });
            },
            onSubmitted: (_) {
              if (!state.isConnecting) {
                dev.log('📤 [RTSP_SCREEN] URL submitted: ${_urlController.text}');
                // Don't immediately update - wait for save button
                _handleSaveStream(state);
              }
            },
            decoration: InputDecoration(
              labelText: S.of(context).enterRtspUrl,
              hintText: S.of(context).hintTextRtspUrl,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              suffixIcon: state.isConnecting 
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                  )
                : null,
            ),
          ),
          const SizedBox(height: 12),
          _buildStreamStatusIndicator(state),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            focusNode: _saveButtonFocusNode,
            onPressed: state.isConnecting 
              ? null // Disable during connection
              : () async {
                  await _handleSaveStream(state);
                },
            icon: state.isConnecting 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(_hasUnsavedChanges ? Icons.save : Icons.check),
            label: Text(
              state.isConnecting 
                ? 'Initializing...' 
                : (_hasUnsavedChanges ? S.of(context).save : S.of(context).save)
            ),
            style: ButtonStyle(
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.focused)) {
                  return Theme.of(context).primaryColor;
                }
                if (_hasUnsavedChanges) {
                  return Colors.orange; // Highlight when there are unsaved changes
                }
                return Colors.white;
              }),
              iconColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.focused)) {
                  return Colors.white;
                }
                return Colors.black;
              }),
              foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.focused)) {
                  return Colors.white;
                }
                return Colors.black;
              }),
            ),
          )
        ],
      ],
    );
  }
}
