import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_notifier.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/rtsp_camera_stream_state.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';

class RTSPCameraSettingsScreen extends ConsumerStatefulWidget {
  const RTSPCameraSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RTSPCameraSettingsScreen> createState() => _RTSPCameraSettingsScreenState();
}

class _RTSPCameraSettingsScreenState extends ConsumerState<RTSPCameraSettingsScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final streamState = ref.read(rtspCameraStreamProvider);
    streamState.whenData((state) {
      _urlController.text = state.rtspUrl ?? '';
    });
  }

  Future<bool> _validateRtspUrl(String url) async {
    if (!url.toLowerCase().startsWith('rtsp://')) {
      return false;
    }

    setState(() => _isValidating = true);

    try {
      await ref.read(rtspCameraStreamProvider.notifier).updateStream(isEnabled: true, url: url);

      await Future.delayed(const Duration(seconds: 2));

      final streamState = ref.read(rtspCameraStreamProvider);
      return streamState.whenOrNull(
            data: (state) => !state.invalidRTSPUrl,
          ) ??
          false;
    } catch (e) {
      log('Rtsp stream validation error: $e');
      return false;
    } finally {
      if (mounted) {
        setState(() => _isValidating = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    if (_urlController.text.isNotEmpty) {
      final isValid = await _validateRtspUrl(_urlController.text);

      if (isValid) {
        await ref.read(rtspCameraStreamProvider.notifier).updateStream(isEnabled: true, url: _urlController.text);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).validRtspUrl),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).invalidRtspUrl),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleEnableToggle(bool value) async {
    if (value && _urlController.text.isNotEmpty) {
      final isValid = await _validateRtspUrl(_urlController.text);
      if (!isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).invalidRtspUrl),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    await ref.read(rtspCameraStreamProvider.notifier).updateStream(isEnabled: value, url: _urlController.text);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streamState = ref.watch(rtspCameraStreamProvider);

    return streamState.when(
      data: (state) => _buildScreen(state.isRTSPEnabled),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildScreen(false),
    );
  }

  Widget _buildScreen(bool isEnabled) {
    return ScreenWithAnimationWidget(
      animation: 'settings',
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        S.of(context).rtspCameraSettings,
                        style: Theme.of(context).textTheme.titleMedium?.apply(fontSizeFactor: 2),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      SwitchListTile(
                        title: Text(S.of(context).enableRtspCamera),
                        value: isEnabled,
                        onChanged: _handleEnableToggle,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Theme.of(context).dividerColor),
                        ),
                      ),
                      if (isEnabled) ...[
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
                          decoration: InputDecoration(
                            labelText: S.of(context).enterRtspUrl,
                            hintText: 'rtsp://username:password@ip:port/stream',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          autofocus: false,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _isValidating
                              ? null
                              : () {
                                  if (_urlController.text.isNotEmpty) {
                                    _saveSettings();
                                  }
                                },
                          icon: _isValidating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(S.of(context).save),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ],
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
