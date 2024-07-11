import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mawaqit/src/pages/quran/widget/quran_player/seek_bar.dart';
import 'package:mawaqit/src/state_management/quran/recite/quran_audio_player_notifier.dart';
import 'package:rxdart/rxdart.dart' as rxdart;

import 'package:mawaqit/const/resource.dart';
import 'package:sizer/sizer.dart';

import 'package:mawaqit/src/state_management/quran/recite/quran_audio_player_state.dart';
import 'package:mawaqit/src/pages/quran/widget/quran_background.dart';

class QuranPlayerScreen extends ConsumerStatefulWidget {
  const QuranPlayerScreen({
    super.key,
  });

  @override
  ConsumerState<QuranPlayerScreen> createState() => _SongScreenState();
}

class _SongScreenState extends ConsumerState<QuranPlayerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quranPlayerNotifierProvider.notifier).play();
    });
  }

  Stream<SeekBarData> get _seekBarDataStream => rxdart.Rx.combineLatest2<Duration, Duration?, SeekBarData>(
          ref.read(quranPlayerNotifierProvider.notifier).positionStream,
          ref.read(quranPlayerNotifierProvider.notifier).audioPlayer.durationStream, (
        Duration position,
        Duration? duration,
      ) {
        return SeekBarData(
          position,
          duration ?? Duration.zero,
        );
      });

  @override
  Widget build(BuildContext context) {
    final quranPlayerState = ref.watch(quranPlayerNotifierProvider);
    return WillPopScope(
      onWillPop: () async {
        ref.read(quranPlayerNotifierProvider.notifier).stop();
        return true;
      },
      child: QuranBackground(
        isSwitch: false,
        screen: quranPlayerState.maybeWhen(
          orElse: () {
            return const SizedBox();
          },
          data: (quranPlayerState) {
            return Stack(
              fit: StackFit.expand,
              children: [
                const _BackgroundFilter(),
                Positioned(
                  child: _QuranPlayer(
                    isPlaying: quranPlayerState.playerState == AudioPlayerState.playing ? true : false,
                    surahName: quranPlayerState.surahName,
                    surahType: quranPlayerState.reciterName,
                    seekBarDataStream: _seekBarDataStream,
                  ),
                  bottom: 0,
                  left: 0,
                  right: 0,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QuranPlayer extends ConsumerWidget {
  const _QuranPlayer({
    super.key,
    required this.surahName,
    required this.surahType,
    required Stream<SeekBarData> seekBarDataStream,
    required this.isPlaying,
  }) : _seekBarDataStream = seekBarDataStream;

  final String surahName;
  final String surahType;
  final bool isPlaying;
  final Stream<SeekBarData> _seekBarDataStream;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quranState = ref.watch(quranPlayerNotifierProvider);

    return Padding(
      padding: EdgeInsets.all(3.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            surahName,
            style: TextStyle(
              fontSize: 5.w,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            surahType,
            style: TextStyle(
              fontSize: 4.w,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 4.h),
          StreamBuilder<SeekBarData>(
            stream: _seekBarDataStream,
            builder: (context, snapshot) {
              final position = snapshot.data?.position ?? Duration.zero;
              final duration = snapshot.data?.duration ?? Duration.zero;
              return Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 10,
                      ),
                      thumbColor: Colors.white,
                      valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                    ),
                    child: Slider(
                      value: position.inSeconds.toDouble(),
                      max: duration.inSeconds.toDouble(),
                      onChanged: (value) {
                        ref.read(quranPlayerNotifierProvider.notifier).seekTo(Duration(seconds: value.toInt()));
                      },
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        position.toString().split('.').first,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Color(0xFFA8A8A8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        duration.toString().split('.').first,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Color(0xFFA8A8A8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              quranState.maybeWhen(
                orElse: () {
                  return const SizedBox();
                },
                data: (data) {
                  if (data.isShuffled) {
                    return IconButton(
                      icon: SvgPicture.asset(
                        R.ASSETS_ICON_SHUFFLE_SVG,
                        color: Colors.white,
                        width: 6.w,
                      ),
                      iconSize: 8.w,
                      onPressed: () {
                        ref.read(quranPlayerNotifierProvider.notifier).shuffle();
                      },
                    );
                  } else {
                    return IconButton(
                      icon: SvgPicture.asset(
                        R.ASSETS_ICON_SHUFFLE_SVG,
                        color: Colors.grey[800],
                        width: 6.w,
                      ),
                      iconSize: 8.w,
                      onPressed: () {
                        ref.read(quranPlayerNotifierProvider.notifier).shuffle();
                      },
                    );
                  }
                },
              ),
              Spacer(),
              IconButton(
                icon: SvgPicture.asset(
                  R.ASSETS_ICON_SKIP_PREVIOUS_SVG,
                  color: Colors.white,
                  width: 6.w,
                ),
                iconSize: 8.w,
                onPressed: () {
                  log('Seeking to previous');
                  ref.read(quranPlayerNotifierProvider.notifier).seekToPrevious();
                },
              ),
              SizedBox(
                width: 2.w,
              ),
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(side: BorderSide.none),
                elevation: 15,
                child: CircleAvatar(
                  backgroundColor: Colors.grey[900],
                  radius: 6.w,
                  child: IconButton(
                    icon: isPlaying
                        ? SvgPicture.asset(
                            R.ASSETS_ICON_PAUSE_SVG,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 8.w,
                          ),
                    iconSize: 10.w,
                    onPressed: () {
                      if (isPlaying) {
                        ref.read(quranPlayerNotifierProvider.notifier).pause();
                      } else {
                        ref.read(quranPlayerNotifierProvider.notifier).play();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 2.w,
              ),
              IconButton(
                icon: SvgPicture.asset(
                  R.ASSETS_ICON_SKIP_NEXT_SVG,
                  color: Colors.white,
                  width: 6.w,
                ),
                iconSize: 8.w,
                onPressed: () {
                  ref.read(quranPlayerNotifierProvider.notifier).seekToNext();
                },
              ),
              Spacer(),
              quranState.maybeWhen(
                orElse: () {
                  return const SizedBox();
                },
                data: (data) {
                  if (data.isRepeating) {
                    return IconButton(
                      icon: SvgPicture.asset(
                        R.ASSETS_ICON_REPEAT_SVG,
                        color: Colors.white,
                        width: 6.w,
                      ),
                      iconSize: 8.w,
                      onPressed: () {
                        ref.read(quranPlayerNotifierProvider.notifier).repeat();
                      },
                    );
                  } else {
                    return IconButton(
                      icon: SvgPicture.asset(
                        R.ASSETS_ICON_REPEAT_SVG,
                        color: Colors.grey[800],
                        width: 6.w,
                      ),
                      iconSize: 8.w,
                      onPressed: () {
                        ref.read(quranPlayerNotifierProvider.notifier).repeat();
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackgroundFilter extends StatelessWidget {
  const _BackgroundFilter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
          Colors.black,
          Colors.black.withOpacity(0.5),
          Colors.black.withOpacity(0.0),
        ], stops: const [
          0.0,
          0.4,
          0.6
        ]).createShader(rect);
      },
      blendMode: BlendMode.dstOut,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E1E1E),
              Color(0xFF1E1E1E),
            ],
          ),
        ),
      ),
    );
  }
}
