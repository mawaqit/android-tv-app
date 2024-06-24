import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/models/announcement.dart';
import 'package:mawaqit/src/state_management/workflow/announcement_workflow/announcement_workflow_notifier.dart';

class FakeAnnouncement extends Announcement {
  FakeAnnouncement({
    required super.id,
    required super.title,
    super.content,
    super.duration,
    super.startDate,
    super.updatedDate,
    super.endDate,
    super.isMobile = false,
    super.isDesktop = true,
    super.image,
    super.video,
  });

  static List<FakeAnnouncement> generateFakeAnnouncements(int count) {
    return List<FakeAnnouncement>.generate(
      count,
      (index) => FakeAnnouncement(
        id: index,
        title: 'Fake Announcement $index',
        content: 'This is the content of fake announcement $index.',
        duration: 5,
        startDate: '2024-05-01',
        updatedDate: '2024-05-20',
        endDate: '2024-05-30',
        isMobile: index % 2 == 0,
        isDesktop: index % 2 != 0,
        image: 'https://example.com/image_$index.png',
        video: index % 2 == 0 ? 'https://example.com/video_$index.mp4' : null,
      ),
    );
  }
}

void main() {
  setUpAll(() {
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) {
        print(message);
      }
    };

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      fail(details.toString());
    };
  });

  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnnouncementWorkflowNotifier Tests', () {
    test('AnnouncementWorkflowNotifier disposal error reproduction', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(announcementWorkflowwProvider.notifier);

      final announcements = FakeAnnouncement.generateFakeAnnouncements(3);

      await notifier.startAnnouncementWorkflow(announcements, true);

      debugPrint('Announcements started.');

      // Wait for some time to let the timer trigger
      await Future.delayed(Duration(seconds: 2));

      // Dispose the notifier and the container
      container.dispose();

      debugPrint('Container disposed.');

      // Wait a bit more to see if any errors occur after disposal
      await Future.delayed(Duration(seconds: 2));
    });

    test('AnnouncementWorkflowNotifier state changes', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(announcementWorkflowwProvider.notifier);

      final announcements = FakeAnnouncement.generateFakeAnnouncements(3);

      await notifier.startAnnouncementWorkflow(announcements, true);

      debugPrint('Announcements started.');

      // Wait for some time to let the timer trigger
      await Future.delayed(Duration(seconds: 10));

      // Dispose the notifier and the container
      container.dispose();

      debugPrint('Container disposed.');

      // Wait a bit more to see if any errors occur after disposal
      await Future.delayed(Duration(seconds: 2));
    });
  });
}
