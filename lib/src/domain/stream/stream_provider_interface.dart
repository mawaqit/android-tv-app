import 'package:flutter/widgets.dart';

/// Abstract interface for stream providers
abstract class StreamProviderInterface {
  /// Initialize stream with given URL
  Future<Widget> initializeStream(String url);
  
  /// Validate if URL is supported by this provider
  bool canHandle(String url);
  
  /// Check if stream is currently active
  Future<bool> isActive();
  
  /// Pause the stream
  Future<void> pause();
  
  /// Resume/play the stream
  Future<void> play();
  
  /// Dispose resources
  Future<void> dispose();
  
  /// Setup error and completion listeners
  void setupListeners({
    required Function(String error) onError,
    required Function() onCompleted,
  });
} 