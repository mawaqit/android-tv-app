import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A service that manages focus traversal throughout the app
/// Especially useful for TV/remote navigation and onboarding flow
class FocusManager {
  // Singleton instance
  static final FocusManager _instance = FocusManager._();
  factory FocusManager() => _instance;
  FocusManager._();

  // Optional timeout duration for focus requests
  Duration defaultTimeout = const Duration(seconds: 2);

  /// Request focus on a node with proper error handling and timeout
  /// Returns whether the focus was successfully requested
  Future<bool> requestFocus(
    FocusNode? node, {
    Duration? timeout,
    bool checkMounted = true,
    BuildContext? context,
  }) async {
    if (node == null || !node.canRequestFocus) {
      return false;
    }

    timeout ??= defaultTimeout;

    // Create a timeout future to avoid getting stuck
    final timeoutFuture = Future.delayed(timeout, () => false);

    try {
      // Request focus after a short delay to ensure widget is built
      final focusResult = await Future.delayed(
        const Duration(milliseconds: 100),
        () {
          if (!node.canRequestFocus) return false;

          // If we're checking for mount state and have a context
          if (checkMounted && context != null) {
            // Only proceed if the context is still mounted
            if (!context.mounted) return false;
          }

          node.requestFocus();
          return true;
        },
      ).timeout(timeout);

      // Return the first completed future (either focus request or timeout)
      return await Future.any([Future.value(focusResult), timeoutFuture]);
    } catch (e) {
      debugPrint("Focus request failed: $e");
      return false;
    }
  }

  /// Reset focus to a fallback focus node after failed focus attempts
  void resetToFallback(FocusNode? fallbackNode, BuildContext context) {
    if (fallbackNode != null && fallbackNode.canRequestFocus && context.mounted) {
      Future.delayed(const Duration(milliseconds: 200), () {
        fallbackNode.requestFocus();
      });
    } else if (context.mounted) {
      // If no fallback provided, at least ensure something has focus
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  /// Handle key-based focus traversal between a list of focus nodes
  KeyEventResult handleFocusTraversal(
    RawKeyEvent event,
    List<FocusNode> orderedNodes,
    int currentIndex, {
    bool wrapAround = true,
    VoidCallback? onUpFromFirst,
    VoidCallback? onDownFromLast,
  }) {
    if (event is! RawKeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (currentIndex < 0 || currentIndex >= orderedNodes.length) {
      return KeyEventResult.ignored;
    }

    // Handle navigation keys
    if (event.logicalKey == LogicalKeyboardKey.arrowDown || event.logicalKey == LogicalKeyboardKey.tab) {
      if (currentIndex == orderedNodes.length - 1) {
        // At last node
        if (onDownFromLast != null) {
          onDownFromLast();
          return KeyEventResult.handled;
        } else if (wrapAround) {
          orderedNodes[0].requestFocus();
          return KeyEventResult.handled;
        }
      } else {
        orderedNodes[currentIndex + 1].requestFocus();
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        (event.logicalKey == LogicalKeyboardKey.tab && event.isShiftPressed)) {
      if (currentIndex == 0) {
        // At first node
        if (onUpFromFirst != null) {
          onUpFromFirst();
          return KeyEventResult.handled;
        } else if (wrapAround) {
          orderedNodes[orderedNodes.length - 1].requestFocus();
          return KeyEventResult.handled;
        }
      } else {
        orderedNodes[currentIndex - 1].requestFocus();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  /// Create a focus listener that updates a current index
  void createFocusListener(FocusNode node, int index, ValueNotifier<int> currentIndexNotifier) {
    node.addListener(() {
      if (node.hasFocus) {
        currentIndexNotifier.value = index;
      }
    });
  }
}

// Provider for dependency injection
final focusManagerProvider = Provider<FocusManager>((ref) {
  return FocusManager();
});
