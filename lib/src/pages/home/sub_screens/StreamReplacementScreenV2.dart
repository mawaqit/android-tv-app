import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../../state_management/livestream_viewer/live_stream_notifier_v2.dart';
import '../../../state_management/livestream_viewer/live_stream_state_v2.dart';
import '../../../widgets/live_stream_widget.dart';

/// Simplified StreamReplacementScreen using refactored components
/// This demonstrates how the new architecture reduces complexity
class StreamReplacementScreenV2 extends ConsumerWidget {
  const StreamReplacementScreenV2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamState = ref.watch(liveStreamProviderV2);

    return streamState.when(
      data: (state) => _buildContent(context, ref, state),
      loading: () => _buildLoadingScreen(),
      error: (error, stack) => _buildErrorScreen(ref),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, LiveStreamState state) {
    // Only show replacement screen if enabled and replacing workflow
    if (!state.isEnabled || !state.replaceWorkflow) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main stream content - using the simplified LiveStreamWidget
          const Center(
            child: LiveStreamWidget(
              showControls: false, // We'll add our own controls
            ),
          ),
          
          // Close button overlay
          _buildCloseButton(ref),
        ],
      ),
    );
  }

  Widget _buildCloseButton(WidgetRef ref) {
    return Positioned(
      top: 8.h,
      right: 4.w,
      child: GestureDetector(
        onTap: () {
          ref.read(liveStreamProviderV2.notifier).toggleReplaceWorkflow(false);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.close,
            color: Colors.white,
            size: 8.w,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(WidgetRef ref) {
    // Disable replacement workflow on error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(liveStreamProviderV2.notifier).toggleReplaceWorkflow(false);
    });
    
    return const SizedBox.shrink();
  }
}

// Example usage in main app:
// 
// class MainApp extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final streamState = ref.watch(liveStreamProviderV2);
//     
//     return streamState.when(
//       data: (state) {
//         // Show replacement screen if workflow replacement is active
//         if (state.replaceWorkflow && state.isReadyToPlay) {
//           return const StreamReplacementScreenV2();
//         }
//         
//         // Otherwise show normal app
//         return const NormalAppFlow();
//       },
//       loading: () => const LoadingScreen(),
//       error: (error, stack) => const ErrorScreen(),
//     );
//   }
// } 