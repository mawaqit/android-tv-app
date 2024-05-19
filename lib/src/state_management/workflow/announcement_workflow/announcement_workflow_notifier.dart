import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/announcement.dart';
import '../../../pages/home/sub_screens/AnnouncementScreen.dart';
import 'announcement_workflow_state.dart';
import '../../../services/user_preferences_manager.dart';

class AnnouncementWorkflowNotifier extends AsyncNotifier<AnnouncementWorkflowState> {
  Timer? _periodicTimer;
  late SharedPreferences sharedPrefs;

  @override
  FutureOr<AnnouncementWorkflowState> build() {
    ref.onDispose(() {
      _closeActivatedTimers();
    });
    return AnnouncementWorkflowState.initial();
  }

  /// Starts the announcement workflow based on the provided announcements and video enable flag.
  ///
  /// @param announcements The list of announcements to be displayed.
  /// @param enableVideo A flag indicating whether videos are enabled.
  Future<void> startAnnouncementWorkflow(List<Announcement> announcements, bool enableVideo) async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      final announcementList = announcements;
      if (announcements.length == 0) return Future.value(state.value);
      sharedPrefs = await SharedPreferences.getInstance();
      final isRepeatingAnnouncementMode = sharedPrefs.getBool(announcementsStoreKey) ?? false;
      log('announcement: AnnouncementWorkflowNotifier: startAnnouncementWorkflow ${announcementList.length} $isRepeatingAnnouncementMode');
      if (isRepeatingAnnouncementMode) {
        _handleRepeatedAnnouncementTimer(announcementList);
      } else {
        _handleLinearAnnouncementTimer(announcementList);
      }
      return Future.value(state.value);
    });
  }

  /// Handles the linear announcement timer for the provided announcements.
  /// it will display the announcements in a linear manner.
  ///
  /// @param announcements The list of announcements to be displayed in a linear manner.
  Future<void> _handleLinearAnnouncementTimer(List<Announcement> announcements) async {
    log('announcement: AnnouncementWorkflowNotifier: _handleLinearAnnouncementTimer');
    for (int i = 0; i < announcements.length; i++) {
      final isRepeatingAnnouncementMode = sharedPrefs.getBool(announcementsStoreKey) ?? false;
      if (isRepeatingAnnouncementMode) {
        log('announcement: AnnouncementWorkflowNotifier: _handleLinearAnnouncementTimer - switching to repeated mode');
        break;
      }
      final announcement = announcements[i];
      final link = announcement.video;
      if (link != null && link != 'null') {
        log('announcement: AnnouncementWorkflowNotifier: _handleLinearAnnouncementTimer - displaying video announcement: $link');
        update(
          (p0) => p0.copyWith(
            announcementItem: AnnouncementWorkFlowItem(
              announcement: announcements[i],
              duration: Duration(seconds: announcement.duration!),
            ),
            isActivated: true,
            currentActivatedIndex: i,
          ),
        );
        // await Future.delayed(Duration(seconds: 20));
        // final duration = ref.read(videoProvider);
        // await Future.delayed(duration);
        // log('announcement: AnnouncementWorkflowNotifier: _handleLinearAnnouncementTimer - video duration: $duration');
      } else {
        log('announcement: AnnouncementWorkflowNotifier: _handleLinearAnnouncementTimer - displaying text announcement: ${announcement.id}');
        update(
          (p0) => p0.copyWith(
            announcementItem: AnnouncementWorkFlowItem(
              announcement: announcements[i],
              duration: Duration(seconds: announcement.duration!),
            ),
            isActivated: true,
            currentActivatedIndex: i,
          ),
        );
        // Wait for the duration of the announcement
        await Future.delayed(Duration(seconds: announcement.duration!));
      }
    }
    log('announcement: AnnouncementWorkflowNotifier: _handleLinearAnnouncementTimer - completed');
    update(
      (p0) => p0.copyWith(
        isActivated: false,
        currentActivatedIndex: 0,
      ),
    );
  }

  /// Handles the repeated announcement timer for the provided announcements.
  ///
  /// @param announcements The list of announcements to be displayed in a repeated manner.
  Future<void> _handleRepeatedAnnouncementTimer(List<Announcement> announcements) async {
    int index = 0;
    log('announcement: AnnouncementWorkflowNotifier: _handleRepeatedAnnouncementTimer');
    while (true) {
      final isRepeatingAnnouncementMode = sharedPrefs.getBool(announcementsStoreKey) ?? false;
      if (!isRepeatingAnnouncementMode) {
        log('announcement: AnnouncementWorkflowNotifier: _handleRepeatedAnnouncementTimer - switching to linear mode');
        break;
      }
      final announcement = announcements[index];
      final link = announcement.video;
      if (link != null && link != 'null') {
        log('announcement: AnnouncementWorkflowNotifier: _handleRepeatedAnnouncementTimer - displaying video announcement: $link');
        update(
          (p0) => p0.copyWith(
            announcementItem: AnnouncementWorkFlowItem(
              announcement: announcements[index],
              duration: Duration(seconds: announcement.duration!),
            ),
            isActivated: true,
            currentActivatedIndex: index,
          ),
        );
        await Future.delayed(Duration(seconds: 20));
        // final duration = ref.read(videoProvider);
        // await Future.delayed(duration);
        // index = (index + 1) % announcements.length; // Move to the next announcement
      } else if (announcement.duration != null) {
        log('announcement: AnnouncementWorkflowNotifier: _handleRepeatedAnnouncementTimer - announcement: ${announcement.id}');
        update(
          (p0) => p0.copyWith(
            announcementItem: AnnouncementWorkFlowItem(
              announcement: announcements[index],
              duration: Duration(seconds: announcement.duration!),
            ),
            isActivated: true,
            currentActivatedIndex: index,
          ),
        );
        // Wait for the duration of the announcement
        await Future.delayed(Duration(seconds: announcement.duration!));
        index = (index + 1) % announcements.length; // Move to the next announcement
      }
    }
  }

  void _closeActivatedTimers() {
    _periodicTimer?.cancel();
    log('announcement: AnnouncementWorkflowNotifier: _closeActivatedTimers - timers disposed');
  }
}

final announcementWorkflowwProvider = AsyncNotifierProvider<AnnouncementWorkflowNotifier, AnnouncementWorkflowState>(
  AnnouncementWorkflowNotifier.new,
);
