import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import '../../../models/announcement.dart';

enum AnnouncementMode {
  repeat,
  linear,
}

enum AnnouncementWorkflowStatus {
  idle,
  loading,
  playing,
  completed,
}

@immutable
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
          updatedDate: '',
        ),
        skip: false,
        disabled: false,
        duration: null,
      );

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

@immutable
class AnnouncementWorkflowState extends Equatable {
  final AnnouncementWorkFlowItem announcementItem;
  final AnnouncementWorkflowStatus status;

  const AnnouncementWorkflowState({
    required this.announcementItem,
    required this.status,
  });

  AnnouncementWorkflowState.initial()
      : this(
          announcementItem: AnnouncementWorkFlowItem.initial(),
          status: AnnouncementWorkflowStatus.idle,
        );

  AnnouncementWorkflowState copyWith({
    AnnouncementWorkFlowItem? announcementItem,
    bool? isActivated,
    AnnouncementWorkflowStatus? status,
  }) {
    return AnnouncementWorkflowState(
      announcementItem: announcementItem ?? this.announcementItem,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        announcementItem,
        status,
      ];

  @override
  String toString() {
    return 'AnnouncementWorkflowState: { announcementItem: ${announcementItem.duration}, '
        'status: $status'
        '}';
  }
}
