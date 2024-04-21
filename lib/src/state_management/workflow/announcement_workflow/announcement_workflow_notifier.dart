import 'dart:async';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/repository/announcement_impl.dart';
import '../../../helpers/time_helper.dart';
import '../../../models/announcement.dart';
import '../../../pages/home/sub_screens/AnnouncementScreen.dart';
import 'announcement_workflow_state.dart';
import '../../../services/user_preferences_manager.dart';

class AnnouncementWorkflowNotifier extends AutoDisposeAsyncNotifier<AnnouncementWorkflowState> {
  late final Timer _timer;
  bool _startLinear = false;
  bool _startRepeated = false;

  @override
  FutureOr<AnnouncementWorkflowState> build() {
    ref.onDispose(() {
      _timer.cancel();
      _startLinear = false;
      _startRepeated = false;
    });
    return AnnouncementWorkflowState.initial();
  }

  /// [startAnnouncement] starts the announcement workflow for the provided announcements.
  Future<void> startAnnouncement([bool isPlayingVideo = true]) async {
    final sharedPreference = await SharedPreferences.getInstance();
    final announcementMode =
        sharedPreference.getBool(announcementsStoreKey) ?? false ? AnnouncementMode.repeat : AnnouncementMode.linear;
    log('announcement: AnnouncementWorkflowNotifier: startAnnouncement $announcementMode');
    state = AsyncLoading();
    try {
      final announcementImpl = await ref.read(announcementRepositoryProvider.future);
      final announcementList = await announcementImpl.getAnnouncements();
      if (announcementMode == AnnouncementMode.repeat) {
        _startRepeated = true;
        await _startRepeatedAnnouncement(announcementList, isPlayingVideo);
      } else {
        _startLinear = true;
        await _startLinearAnnouncement(announcementList, isPlayingVideo);
      }
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  /// Handles the linear announcement timer for the provided announcements.
  /// it will display the announcements in a linear manner.
  ///
  /// @param announcements The list of announcements to be displayed in a linear manner.
  Future<void> _startLinearAnnouncement(List<Announcement> announcements, bool isPlayingVideo) async {
    log('announcement: AnnouncementWorkflowNotifier: _startLinearAnnouncement');
    announcements =
        announcements.where((element) => TimeHelper.isBetweenStartAndEnd(element.startDate, element.endDate)).toList();
    log('announcement: AnnouncementWorkflowNotifier: initial $announcements');
    for (int i = 0; i < announcements.length; i++) {
      if (!_startLinear) return;
      final announcementMode = await _getAnnouncementMode();
      if (announcementMode == AnnouncementMode.repeat) {
        log('announcement: AnnouncementWorkflowNotifier: _startRepeatedAnnouncement - switching to linear mode');
        break;
      }
      final announcement = announcements[i];
      await _displayAnnouncement(announcement, isPlayingVideo);
    }
    log('announcement: AnnouncementWorkflowNotifier: _startLinearAnnouncement - completed');
    state = AsyncData(
      state.value!.copyWith(
        status: AnnouncementWorkflowStatus.completed,
      ),
    );
  }

  /// Handles the repeated announcement timer for the provided announcements.
  ///
  /// @param announcements The list of announcements to be displayed in a repeated manner.
  Future<void> _startRepeatedAnnouncement(List<Announcement> announcements, bool isPlayingVideo) async {
    log('announcement: AnnouncementWorkflowNotifier: _startRepeatedAnnouncement');
    announcements =
        announcements.where((element) => TimeHelper.isBetweenStartAndEnd(element.startDate, element.endDate)).toList();
    log('announcement: AnnouncementWorkflowNotifier: _startRepeatedAnnouncement initial $announcements');
    int index = 0;

    final announcementImpl = await ref.read(announcementRepositoryProvider.future);
    final announcementStream = announcementImpl.getAnnouncementsStream();
    final streamSubscription = announcementStream.listen(
      (updatedAnnouncements) {
        announcements = updatedAnnouncements
            .where((element) => TimeHelper.isBetweenStartAndEnd(element.startDate, element.endDate))
            .toList();
        log('announcement: AnnouncementWorkflowNotifier: _startRepeatedAnnouncement $announcements');
      },
      onError: (e, stackTrace) {
        state = AsyncError(e, stackTrace);
      },
    );
    ref.onDispose(() {
      streamSubscription.cancel();
    });
    while (_startRepeated) {
      final announcementMode = await _getAnnouncementMode();
      log('announcement: AnnouncementWorkflowNotifier: _startRepeatedAnnouncement - outside: $index');
      if (announcementMode == AnnouncementMode.linear) {
        log('announcement: AnnouncementWorkflowNotifier: _startRepeatedAnnouncement - switching to linear mode');
        break;
      }
      final announcement = announcements[index];
      await _displayAnnouncement(announcement, isPlayingVideo);
      index = (index + 1) % announcements.length;
    }
  }

  /// [_displayAnnouncement] displays the provided announcement. if it is video it will play
  /// the video based on videoProvider to get the duration of the video.
  /// if it is text it will display the text for the provided duration or image
  Future<void> _displayAnnouncement(Announcement announcement, bool isPlayingVideo) async {
    final link = announcement.video;
    log('announcement: AnnouncementWorkflowNotifier: _displayAnnouncement: $isPlayingVideo');
    if (isPlayingVideo && link != null && link != 'null') {
      log('announcement: AnnouncementWorkflowNotifier: _displayAnnouncement: video ${announcement.id}');
      state = AsyncData(
        state.value!.copyWith(
          announcementItem: AnnouncementWorkFlowItem(
            announcement: announcement,
            duration: Duration(seconds: announcement.duration!),
          ),
          status: AnnouncementWorkflowStatus.playing,
        ),
      );
      await Future.delayed(Duration(seconds: 5));
      final duration = ref.read(videoProvider);
      await Future.delayed(duration);
    } else if (announcement.duration != null && link == null) {
      // link checks if it is a video or not
      log('announcement: AnnouncementWorkflowNotifier: _displayAnnouncement: text ${announcement.id}');
      state = AsyncData(
        state.value!.copyWith(
          announcementItem: AnnouncementWorkFlowItem(
            announcement: announcement,
            duration: Duration(seconds: announcement.duration!),
          ),
          status: AnnouncementWorkflowStatus.playing,
        ),
      );
      await Future.delayed(Duration(seconds: announcement.duration!));
    }
  }

  Future<AnnouncementMode> _getAnnouncementMode() async {
    final sharedPreference = await SharedPreferences.getInstance();
    final announcementBool = sharedPreference.getBool(announcementsStoreKey) ?? false;
    return announcementBool ? AnnouncementMode.repeat : AnnouncementMode.linear;
  }
}

final announcementWorkflowProvider =
    AutoDisposeAsyncNotifierProvider<AnnouncementWorkflowNotifier, AnnouncementWorkflowState>(
  AnnouncementWorkflowNotifier.new,
);
