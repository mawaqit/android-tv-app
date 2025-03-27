import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'camera_stream_overlay_notifier.dart';

class StreamOverlaySettings extends Equatable {
  final bool autoOverlayEnabled;
  final bool isOverlayActive;

  const StreamOverlaySettings({
    this.autoOverlayEnabled = false,
    this.isOverlayActive = false,
  });

  StreamOverlaySettings copyWith({
    bool? autoOverlayEnabled,
    bool? isOverlayActive,
  }) {
    return StreamOverlaySettings(
      autoOverlayEnabled: autoOverlayEnabled ?? this.autoOverlayEnabled,
      isOverlayActive: isOverlayActive ?? this.isOverlayActive,
    );
  }

  @override
  List<Object?> get props => [autoOverlayEnabled, isOverlayActive];
}
