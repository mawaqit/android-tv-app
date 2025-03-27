import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/pages/stream_overlay.dart';
import 'package:mawaqit/src/state_management/rtsp_camera_stream/camera_stream_overlay_notifier.dart';

class AppWrapper extends ConsumerWidget {
  final Widget child;

  const AppWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlaySettings = ref.watch(streamOverlaySettingsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          // Your regular app
          child,
          // Show stream overlay when active
          if (overlaySettings.autoOverlayEnabled) const StreamOverlay(),
        ],
      ),
    );
  }
}
