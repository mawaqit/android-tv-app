import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// Enumeration of stream types supported by the livestream viewer
enum LiveStreamType { rtsp, youtubeLive }

/// Enumeration of stream statuses
enum LiveStreamStatus {
  idle,
  active,
  error,
  ended,
  connecting,
  unreliable,
}

/// Simplified state class for livestream viewer feature
/// This version removes the complexity of storing multiple controllers
class LiveStreamState extends Equatable {
  /// Whether livestream is enabled
  final bool isEnabled;

  /// URL of the stream
  final String? streamUrl;

  /// Type of stream (RTSP or YouTube)
  final LiveStreamType? streamType;

  /// Stream widget (can be YouTube player or Video widget)
  final Widget? streamWidget;

  /// Whether URL is invalid
  final bool isInvalidUrl;

  /// Whether to replace the main workflow with the stream
  final bool replaceWorkflow;

  /// Current status of the stream
  final LiveStreamStatus streamStatus;

  /// Error message if any
  final String? errorMessage;

  const LiveStreamState({
    this.isEnabled = false,
    this.streamUrl,
    this.streamType,
    this.streamWidget,
    this.isInvalidUrl = false,
    this.replaceWorkflow = false,
    this.streamStatus = LiveStreamStatus.idle,
    this.errorMessage,
  });

  /// Create a copy of this state with specified attributes replaced
  LiveStreamState copyWith({
    bool? isEnabled,
    String? streamUrl,
    LiveStreamType? streamType,
    Widget? streamWidget,
    bool? isInvalidUrl,
    bool? replaceWorkflow,
    LiveStreamStatus? streamStatus,
    String? errorMessage,
  }) {
    return LiveStreamState(
      isEnabled: isEnabled ?? this.isEnabled,
      streamUrl: streamUrl ?? this.streamUrl,
      streamType: streamType ?? this.streamType,
      streamWidget: streamWidget ?? this.streamWidget,
      isInvalidUrl: isInvalidUrl ?? this.isInvalidUrl,
      replaceWorkflow: replaceWorkflow ?? this.replaceWorkflow,
      streamStatus: streamStatus ?? this.streamStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Check if stream is ready to be displayed
  bool get isReadyToPlay => 
      isEnabled && 
      streamWidget != null && 
      streamStatus == LiveStreamStatus.active;

  /// Check if stream has error
  bool get hasError => 
      streamStatus == LiveStreamStatus.error || 
      isInvalidUrl;

  /// Check if stream is in connecting state
  bool get isConnecting => 
      streamStatus == LiveStreamStatus.connecting;

  @override
  List<Object?> get props => [
        isEnabled,
        streamUrl,
        streamType,
        streamWidget,
        isInvalidUrl,
        replaceWorkflow,
        streamStatus,
        errorMessage,
      ];

  @override
  String toString() {
    return 'LiveStreamState{isEnabled: $isEnabled, streamUrl: $streamUrl, streamType: $streamType, hasWidget: ${streamWidget != null}, isInvalidUrl: $isInvalidUrl, replaceWorkflow: $replaceWorkflow, streamStatus: $streamStatus, errorMessage: $errorMessage}';
  }
} 