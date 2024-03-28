import 'package:equatable/equatable.dart';
import '../../../models/announcement.dart';

class AnnouncementWorkFlowItem extends Equatable {
  final Announcement announcement;
  final bool skip, disabled;
  final Duration? duration;

  const AnnouncementWorkFlowItem({
    required this.announcement,
    this.skip = false,
    this.duration,
    this.disabled = false,
  });

  factory AnnouncementWorkFlowItem.initial() => AnnouncementWorkFlowItem(
      announcement: Announcement(
        isDesktop: false,
        id: 0,
        isMobile: false,
        title: '',
        content: '',
        image: '',
        video: '',
        duration: 0,
        startDate: '',
        endDate: '',
        updatedDate: '',
      ),
      skip: false,
      disabled: false,
      duration: null);

  AnnouncementWorkFlowItem copyWith({
    Announcement? announcement,
    bool? skip,
    bool? disabled,
    Duration? duration,
  }) {
    return AnnouncementWorkFlowItem(
      announcement: announcement ?? this.announcement,
      skip: skip ?? this.skip,
      disabled: disabled ?? this.disabled,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object?> get props => [announcement, skip, disabled, duration];
}

class AnnouncementWorkflowState extends Equatable {
  final AnnouncementWorkFlowItem announcementItem;
  final bool isActivated;
  final int currentActivatedIndex;

  const AnnouncementWorkflowState({
    required this.announcementItem,
    this.isActivated = false,
    required this.currentActivatedIndex,
  });

  AnnouncementWorkflowState.initial()
      : this(
          announcementItem: AnnouncementWorkFlowItem.initial(),
          isActivated: true,
          currentActivatedIndex: 0,
        );

  AnnouncementWorkflowState copyWith({
    AnnouncementWorkFlowItem? announcementItem,
    bool? isActivated,
    int? currentActivatedIndex,
  }) {
    return AnnouncementWorkflowState(
      currentActivatedIndex: currentActivatedIndex ?? this.currentActivatedIndex,
      announcementItem: announcementItem ?? this.announcementItem,
      isActivated: isActivated ?? this.isActivated,
    );
  }

  @override
  List<Object?> get props => [announcementItem, isActivated, currentActivatedIndex];

  @override
  String toString() {
    return 'AnnouncementWorkflowState: { announcementItem: ${announcementItem.duration}, isActivated: $isActivated, currentActivatedIndex: $currentActivatedIndex }';
  }
}
