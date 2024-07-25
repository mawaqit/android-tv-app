import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final FocusNode backButtonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quranPlayerNotifierProvider.notifier).play();
    });
  }

  @override
  void dispose() {
    backButtonFocusNode.dispose();
    super.dispose();
  }

  Stream<SeekBarData> get _seekBarDataStream =>
      rxdart.Rx.combineLatest2<Duration, Duration?, SeekBarData>(
          ref.read(quranPlayerNotifierProvider.notifier).positionStream,
          ref
              .read(quranPlayerNotifierProvider.notifier)
              .audioPlayer
              .durationStream, (
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
        // switchFocusNode: FocusNode(),
        isSwitch: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: Focus(
            focusNode: backButtonFocusNode,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                ref.read(quranPlayerNotifierProvider.notifier).stop();
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
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
                    backButtonFocusNode: backButtonFocusNode,
                    isPlaying:
                        quranPlayerState.playerState == AudioPlayerState.playing
                            ? true
                            : false,
                    surahName: quranPlayerState.surahName,
                    surahType: quranPlayerState.reciterName,
                    seekBarDataStream: _seekBarDataStream,
                    onFocusBackButton: () => backButtonFocusNode.requestFocus(),
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

class _QuranPlayer extends ConsumerStatefulWidget {
  const _QuranPlayer({
    super.key,
    required this.surahName,
    required this.surahType,
    required Stream<SeekBarData> seekBarDataStream,
    required this.isPlaying,
    required this.onFocusBackButton,
    required this.backButtonFocusNode,
  }) : _seekBarDataStream = seekBarDataStream;

  final VoidCallback onFocusBackButton;
  final String surahName;
  final String surahType;
  final bool isPlaying;
  final FocusNode backButtonFocusNode;
  final Stream<SeekBarData> _seekBarDataStream;

  @override
  ConsumerState<_QuranPlayer> createState() => _QuranPlayerState();
}

class _QuranPlayerState extends ConsumerState<_QuranPlayer> {
  late final FocusNode leftFocusNode;
  late final FocusNode rightFocusNode;
  late final FocusNode shuffleFocusNode;
  late final FocusNode repeatFocusNode;
  late final FocusNode sliderFocusNode;
  Color _sliderThumbColor = Colors.white;

  @override
  void initState() {
    super.initState();
    leftFocusNode = FocusNode();
    rightFocusNode = FocusNode();
    shuffleFocusNode = FocusNode();
    repeatFocusNode = FocusNode();
    sliderFocusNode = FocusNode();
    sliderFocusNode.addListener(_setSliderThumbColor);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      leftFocusNode.requestFocus();
    });
  }

  _setSliderThumbColor() {
    setState(() {
      if (sliderFocusNode.hasFocus) {
        _sliderThumbColor = Color(0xFF490094);
      } else {
        _sliderThumbColor = Colors.white;
      }
    });
  }

  @override
  void dispose() {
    shuffleFocusNode.dispose();
    repeatFocusNode.dispose();
    leftFocusNode.dispose();
    rightFocusNode.dispose();
    sliderFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quranState = ref.watch(quranPlayerNotifierProvider);
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(3.w),
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.surahName,
              style: TextStyle(
                fontSize: 5.w,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              widget.surahType,
              style: TextStyle(
                fontSize: 4.w,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 4.h),
            StreamBuilder<SeekBarData>(
              stream: widget._seekBarDataStream,
              builder: (context, snapshot) {
                final position = snapshot.data?.position ?? Duration.zero;
                final duration = snapshot.data?.duration ?? Duration.zero;
                return Column(
                  children: [
                    FocusTraversalOrder(
                      order: NumericFocusOrder(0),
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 10,
                          ),
                          thumbColor: Colors.white,
                          valueIndicatorShape:
                              const PaddleSliderValueIndicatorShape(),
                        ),
                        child: MediaQuery(
                          data: MediaQueryData(
                            navigationMode: NavigationMode.directional,
                          ),
                          child: SliderTheme(
                            data: SliderThemeData(
                              thumbColor: _sliderThumbColor,
                            ),
                            child: Slider(
                              focusNode: sliderFocusNode,
                              value: position.inSeconds.toDouble(),
                              max: duration.inSeconds.toDouble(),
                              onChanged: (value) {
                                ref
                                    .read(quranPlayerNotifierProvider.notifier)
                                    .seekTo(Duration(seconds: value.toInt()));
                              },
                            ),
                          ),
                        ),
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
            FocusTraversalOrder(
              order: NumericFocusOrder(1),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    quranState.maybeWhen(
                      orElse: () {
                        return const SizedBox();
                      },
                      data: (data) {
                        return FocusableActionDetector(
                          focusNode: shuffleFocusNode,
                          actions: <Type, Action<Intent>>{
                            ActivateIntent: CallbackAction<ActivateIntent>(
                              onInvoke: (ActivateIntent intent) {
                                ref
                                    .read(quranPlayerNotifierProvider.notifier)
                                    .shuffle();
                                return null;
                              },
                            ),
                          },
                          onFocusChange: (hasFocus) {
                            setState(() {});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: shuffleFocusNode.hasFocus
                                  ? theme.primaryColor
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: SvgPicture.asset(
                                R.ASSETS_ICON_SHUFFLE_SVG,
                                color: data.isShuffled
                                    ? Colors.white
                                    : Colors.grey[800],
                                width: 6.w,
                              ),
                              iconSize: 8.w,
                              onPressed: () {
                                ref
                                    .read(quranPlayerNotifierProvider.notifier)
                                    .shuffle();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    Spacer(),
                    FocusableActionDetector(
                      focusNode: leftFocusNode,
                      onFocusChange: (hasFocus) {
                        setState(() {});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: leftFocusNode.hasFocus
                              ? theme.primaryColor
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: SvgPicture.asset(
                            R.ASSETS_ICON_SKIP_PREVIOUS_SVG,
                            color: Colors.white,
                            width: 6.w,
                          ),
                          iconSize: 8.w,
                          onPressed: () {
                            ref
                                .read(quranPlayerNotifierProvider.notifier)
                                .seekToPrevious();
                          },
                        ),
                      ),
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
                          icon: widget.isPlaying
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
                            if (widget.isPlaying) {
                              ref
                                  .read(quranPlayerNotifierProvider.notifier)
                                  .pause();
                            } else {
                              ref
                                  .read(quranPlayerNotifierProvider.notifier)
                                  .play();
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 2.w,
                    ),
                    FocusableActionDetector(
                      focusNode: rightFocusNode,
                      onFocusChange: (hasFocus) {
                        setState(() {});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: rightFocusNode.hasFocus
                              ? theme.primaryColor
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: SvgPicture.asset(
                            R.ASSETS_ICON_SKIP_NEXT_SVG,
                            color: Colors.white,
                            width: 6.w,
                          ),
                          iconSize: 8.w,
                          onPressed: () {
                            ref
                                .read(quranPlayerNotifierProvider.notifier)
                                .seekToNext();
                          },
                        ),
                      ),
                    ),
                    Spacer(),
                    quranState.maybeWhen(
                      orElse: () {
                        return const SizedBox();
                      },
                      data: (data) {
                        return FocusableActionDetector(
                          focusNode: repeatFocusNode,
                          onFocusChange: (hasFocus) {
                            setState(() {});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: repeatFocusNode.hasFocus
                                  ? theme.primaryColor
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: SvgPicture.asset(
                                R.ASSETS_ICON_REPEAT_SVG,
                                color: data.isRepeating
                                    ? Colors.white
                                    : Colors.grey[800],
                                width: 6.w,
                              ),
                              iconSize: 8.w,
                              onPressed: () {
                                ref
                                    .read(quranPlayerNotifierProvider.notifier)
                                    .repeat();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
        return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.0),
            ],
            stops: const [
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
