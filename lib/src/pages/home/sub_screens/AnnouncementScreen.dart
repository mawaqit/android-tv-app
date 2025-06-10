import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/mawaqit_image/mawaqit_image_cache.dart';
import 'package:mawaqit/src/models/announcement.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';
import 'package:mawaqit/src/pages/home/widgets/AboveSalahBar.dart';
import 'package:mawaqit/src/pages/home/widgets/workflows/WorkFlowWidget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../services/user_preferences_manager.dart';
import '../../../state_management/workflow/announcement_workflow.dart';
import '../../../state_management/workflow/workflow_notifier.dart';
import '../widgets/salah_items/responsive_mini_salah_bar_turkish_widget.dart';
import '../widgets/salah_items/responsive_mini_salah_bar_widget.dart';
import '../widgets/workflows/announcement_workflow.dart';

/// show all announcements one after another
class AnnouncementScreen extends ConsumerStatefulWidget {
  AnnouncementScreen({
    Key? key,
    this.onDone,
    this.enableVideos = true,
  }) : super(key: key);

  final VoidCallback? onDone;

  /// used to disable videos on mosques
  final bool enableVideos;

  @override
  ConsumerState<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends ConsumerState<AnnouncementScreen> {
  Announcement? currentAnnouncement;

  @override
  Widget build(BuildContext context) {
    final announcements = context.read<MosqueManager>().activeAnnouncements(widget.enableVideos);
    ref.listen(announcementWorkflowProvider, (prev, next) {
      if (next == WorkflowState.finished) widget.onDone?.call();
    });
    bool? showPrayerTimesOnMessageScreen =
        context.select<MosqueManager, bool?>((mosque) => mosque.mosqueConfig!.showPrayerTimesOnMessageScreen);
    bool announcementMode =
        context.select<UserPreferencesManager, bool>((userPreference) => userPreference.announcementsOnly);
    if (announcements.isEmpty) return NormalHomeSubScreen();
    final mosqueProvider = context.read<MosqueManager>();

    return OrientationBuilder(
      builder: (context, orientation) {
        final isImageAnnouncement = currentAnnouncement?.image != null;
        return switch (orientation) {
          Orientation.portrait => Column(
              children: [
                SizedBox(height: 1.h),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.vh),
                    child: AboveSalahBar(),
                  ),
                ),
                Flexible(
                  flex: 7,
                  child: AnnouncementContinuesWorkFlowWidget(
                    workFlowItems: announcements
                        .map((e) => AnnouncementWorkFlowItem(
                              builder: (context) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  setState(() {
                                    currentAnnouncement = e;
                                  });
                                });
                                return announcementWidgets(e);
                              },
                              duration: e.video != null ? null : Duration(seconds: e.duration ?? 30),
                            ))
                        .toList(),
                  ),
                ),
                Flexible(
                  flex: isImageAnnouncement ? 0 : 3,
                  child: _buildPrayerTimesWidget(
                      context, mosqueProvider, announcementMode, showPrayerTimesOnMessageScreen),
                ),
                SizedBox(height: 1.h),
              ],
            ),
          Orientation.landscape => Stack(
              alignment: Alignment.bottomCenter,
              children: [
                AnnouncementContinuesWorkFlowWidget(
                  workFlowItems: announcements
                      .map((e) => AnnouncementWorkFlowItem(
                            builder: (context) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(() {
                                  currentAnnouncement = e;
                                });
                              });
                              return announcementWidgets(e);
                            },
                            duration: e.video != null ? null : Duration(seconds: e.duration ?? 30),
                          ))
                      .toList(),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.vh),
                    child: AboveSalahBar(),
                  ),
                ),
                _buildPrayerTimesWidget(context, mosqueProvider, announcementMode, showPrayerTimesOnMessageScreen),
              ],
            ),
        };
      },
    );
  }

  Widget _buildPrayerTimesWidget(
      BuildContext context, MosqueManager mosqueProvider, bool announcementMode, bool? showPrayerTimesOnMessageScreen) {
    final isImageAnnouncement = currentAnnouncement?.image != null;

    return announcementMode
        ? ((showPrayerTimesOnMessageScreen ?? false) && !isImageAnnouncement
            ? IgnorePointer(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 1.5.vh),
                  child: mosqueProvider.times!.isTurki
                      ? ResponsiveMiniSalahBarTurkishWidget()
                      : ResponsiveMiniSalahBarWidget(),
                ),
              )
            : const SizedBox.shrink())
        : !isImageAnnouncement
            ? IgnorePointer(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 1.5.vh),
                  child: mosqueProvider.times!.isTurki
                      ? ResponsiveMiniSalahBarTurkishWidget()
                      : ResponsiveMiniSalahBarWidget(),
                ),
              )
            : const SizedBox.shrink();
  }

  /// return the widget of the announcement based on its type
  Widget announcementWidgets(Announcement activeAnnouncement, {VoidCallback? nextAnnouncement}) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    if (activeAnnouncement.content != null) {
      return isPortrait
          ? _TextAnnouncement.portrait(
              title: activeAnnouncement.title,
              content: activeAnnouncement.content!,
            )
          : _TextAnnouncement.landscape(
              title: activeAnnouncement.title,
              content: activeAnnouncement.content!,
            );
    } else if (activeAnnouncement.image != null) {
      return _ImageAnnouncement(
        image: activeAnnouncement.image!,
        onError: nextAnnouncement,
      );
    } else if (activeAnnouncement.video != null) {
      return _VideoAnnouncement(
        key: ValueKey(activeAnnouncement.video),
        url: activeAnnouncement.video!,
        onEnded: nextAnnouncement, // Make sure this is correctly called when the video ends
      );
    }

    return SizedBox();
  }
}

class _TextAnnouncement extends StatelessWidget {
  const _TextAnnouncement._internal({
    Key? key,
    required this.title,
    required this.content,
    required this.isPortrait,
  }) : super(key: key);

  factory _TextAnnouncement.portrait({
    Key? key,
    required String title,
    required String content,
  }) {
    return _TextAnnouncement._internal(
      key: key,
      title: title,
      content: content,
      isPortrait: true,
    );
  }

  factory _TextAnnouncement.landscape({
    Key? key,
    required String title,
    required String content,
  }) {
    return _TextAnnouncement._internal(
      key: key,
      title: title,
      content: content,
      isPortrait: false,
    );
  }

  final String title;
  final String content;
  final bool isPortrait;

  @override
  Widget build(BuildContext context) {
    return switch (isPortrait) {
      false => Padding(
          key: ValueKey("$content $title"),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              // title
              SizedBox(height: 10.vh),
              Flexible(
                flex: 6,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: AutoSizeText(
                    title ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      shadows: kAnnouncementTextShadow,
                      fontSize: 6.vwr,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                      letterSpacing: 1,
                    ),
                  ).animate().slide().addRepaintBoundary(),
                ),
              ),
              // content
              SizedBox(height: 5.vh),
              Flexible(
                flex: 24,
                child: AutoSizeText(
                  content,
                  stepGranularity: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    shadows: kAnnouncementTextShadow,
                    fontSize: 6.vwr,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ).animate().fade(delay: 500.milliseconds).addRepaintBoundary(),
              ),
              SizedBox(height: 20.vh),
            ],
          ),
        ),
      true => Padding(
          key: ValueKey("$content $title"),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Spacer(flex: 1),
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: AutoSizeText(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    shadows: kAnnouncementTextShadow,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                    letterSpacing: 1,
                  ),
                ).animate().slide().addRepaintBoundary(),
              ),
              Flexible(
                flex: 10,
                child: AutoSizeText(
                  content,
                  stepGranularity: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    shadows: kAnnouncementTextShadow,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  maxLines: 10,
                  minFontSize: 10,
                ).animate().fade(delay: 500.milliseconds).addRepaintBoundary(),
              ),
              Spacer(flex: 1),
            ],
          ),
        ),
    };
  }

  get kAnnouncementTextShadow => [
        Shadow(
          offset: Offset(0, 9),
          blurRadius: 15,
          color: Colors.black54,
        ),
      ];
}

class _ImageAnnouncement extends StatelessWidget {
  const _ImageAnnouncement({
    Key? key,
    required this.image,
    this.onError,
  }) : super(key: key);

  final String image;

  /// used to skip to the next announcement if the image failed to load
  final VoidCallback? onError;

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return isPortrait
        ? Image(
            image: MawaqitNetworkImageProvider(image, onError: onError),
            fit: BoxFit.fitWidth,
            width: double.infinity,
          ).animate().slideX().addRepaintBoundary()
        : Image(
            image: MawaqitNetworkImageProvider(image, onError: onError),
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ).animate().slideX().addRepaintBoundary();
  }
}

class _VideoAnnouncement extends ConsumerStatefulWidget {
  const _VideoAnnouncement({
    Key? key,
    required this.url,
    this.onEnded,
  }) : super(key: key);

  final String url;
  final VoidCallback? onEnded;

  @override
  ConsumerState<_VideoAnnouncement> createState() => _VideoAnnouncementState();
}

class _VideoAnnouncementState extends ConsumerState<_VideoAnnouncement> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    final mosqueManager = context.read<MosqueManager>();

    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.url)!,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: mosqueManager.typeIsMosque,
        useHybridComposition: false,
        hideControls: true,
        forceHD: true,
      ),
    );

    /// if announcement didn't started playing after 20 seconds skip it
    Future.delayed(20.seconds, () {
      if (_controller.value.isReady == false) widget.onEnded?.call();
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          onEnded: (metaData) {
            ref.read(videoWorkflowProvider.notifier).setVideoFinished();
            widget.onEnded?.call();
          },
        ),
      ),
    );
  }
}
