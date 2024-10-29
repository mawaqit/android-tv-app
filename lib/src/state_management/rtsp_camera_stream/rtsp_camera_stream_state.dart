import 'package:equatable/equatable.dart';

class RtspCameraStreamState extends Equatable {
  final bool isRTSPEnabled;
  final String? rtspUrl;
  final bool isRTSPInitialized;
  final bool invalidRTSPUrl;
  final bool invalidStreamUrl;
  final int retryCount;

  const RtspCameraStreamState({
    required this.isRTSPEnabled,
    required this.rtspUrl,
    required this.isRTSPInitialized,
    required this.invalidRTSPUrl,
    required this.invalidStreamUrl,
    required this.retryCount,
  });

  RtspCameraStreamState copyWith({
    bool? isRTSPEnabled,
    String? rtspUrl,
    bool? isRTSPInitialized,
    bool? invalidRTSPUrl,
    bool? invalidStreamUrl,
    int? retryCount,
  }) {
    return RtspCameraStreamState(
      isRTSPEnabled: isRTSPEnabled ?? this.isRTSPEnabled,
      rtspUrl: rtspUrl ?? this.rtspUrl,
      isRTSPInitialized: isRTSPInitialized ?? this.isRTSPInitialized,
      invalidRTSPUrl: invalidRTSPUrl ?? this.invalidRTSPUrl,
      invalidStreamUrl: invalidStreamUrl ?? this.invalidStreamUrl,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  List<Object?> get props => [
        isRTSPEnabled,
        rtspUrl,
        isRTSPInitialized,
        invalidRTSPUrl,
        invalidStreamUrl,
        retryCount,
      ];
}
