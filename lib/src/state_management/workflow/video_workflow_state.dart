class VideoWorkflowState {
  /// True if the video is finished, false otherwise.
  final bool isVideoFinished;

  VideoWorkflowState(this.isVideoFinished);

  @override
  String toString() {
    return 'VideoWorkflowState: $isVideoFinished';
  }
}
