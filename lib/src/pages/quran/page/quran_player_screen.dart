import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mawaqit/src/pages/quran/page/surah_selection_screen.dart';
import 'package:mawaqit/src/pages/quran/widget/quran_player/seek_bar.dart';
import 'package:mawaqit/src/state_management/quran/recite/quran_audio_player_notifier.dart';
import 'package:rxdart/rxdart.dart' as rxdart;
import 'package:mawaqit/const/resource.dart';
import 'package:sizer/sizer.dart';
import 'package:mawaqit/src/state_management/quran/recite/quran_audio_player_state.dart';
import 'package:mawaqit/src/pages/quran/widget/quran_background.dart';
import 'dart:math' as math;

class QuranPlayerScreen extends ConsumerStatefulWidget {
  const QuranPlayerScreen({super.key});

  @override
  ConsumerState<QuranPlayerScreen> createState() => _QuranPlayerScreenState();
}

class _QuranPlayerScreenState extends ConsumerState<QuranPlayerScreen> {
  final FocusNode backButtonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quranPlayerNotifierProvider.notifier).play();
      backButtonFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    backButtonFocusNode.dispose();
    super.dispose();
  }

  Stream<SeekBarData> get _seekBarDataStream => rxdart.Rx.combineLatest2<Duration, Duration?, SeekBarData>(
          ref.read(quranPlayerNotifierProvider.notifier).positionStream,
          ref.read(quranPlayerNotifierProvider.notifier).audioPlayer.durationStream,
          (Duration position, Duration? duration) {
        return SeekBarData(position, duration ?? Duration.zero);
      });

  @override
  Widget build(BuildContext context) {
    final quranPlayerState = ref.watch(quranPlayerNotifierProvider);
    return WillPopScope(
      onWillPop: () async {
        ref.read(quranPlayerNotifierProvider.notifier).stop();
        ref.read(navigateIntoNewPageProvider.notifier).state = false;
        return true;
      },
      child: QuranBackground(
        isSwitch: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: Focus(
            focusNode: backButtonFocusNode,
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                log('Back button focused');
              }
            },
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
                    isPlaying: quranPlayerState.playerState == AudioPlayerState.playing,
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
  late final FocusScopeNode volumeFocusNode;
  late final FocusNode playFocusNode;
  Color _sliderThumbColor = Colors.white;

  @override
  void initState() {
    super.initState();
    leftFocusNode = FocusNode();
    rightFocusNode = FocusNode();
    shuffleFocusNode = FocusNode();
    repeatFocusNode = FocusNode();
    volumeFocusNode = FocusScopeNode();
    playFocusNode = FocusNode();
    sliderFocusNode = FocusNode();
    sliderFocusNode.addListener(_setSliderThumbColor);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      playFocusNode.requestFocus();
    });
  }

  _setSliderThumbColor() {
    setState(() {
      _sliderThumbColor = sliderFocusNode.hasFocus ? Color(0xFF490094) : Colors.white;
    });
  }

  @override
  void dispose() {
    shuffleFocusNode.dispose();
    repeatFocusNode.dispose();
    leftFocusNode.dispose();
    volumeFocusNode.dispose();
    rightFocusNode.dispose();
    sliderFocusNode.dispose();
    playFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quranState = ref.watch(quranPlayerNotifierProvider);
    final directionality = Directionality.of(context);
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
                          valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
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
                                ref.read(quranPlayerNotifierProvider.notifier).seekTo(Duration(seconds: value.toInt()));
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        quranState.maybeWhen(
                          orElse: () => const SizedBox(),
                          data: (data) {
                            return FocusableActionDetector(
                              focusNode: repeatFocusNode,
                              onFocusChange: (hasFocus) {
                                setState(() {});
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: repeatFocusNode.hasFocus ? theme.primaryColor : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: SvgPicture.asset(
                                    R.ASSETS_ICON_REPEAT_SVG,
                                    color: data.isRepeating || repeatFocusNode.hasFocus
                                        ? Colors.white
                                        : Colors.grey[800],
                                    width: 6.w,
                                  ),
                                  iconSize: 8.w,
                                  onPressed: () {
                                    ref.read(quranPlayerNotifierProvider.notifier).repeat();
                                    repeatFocusNode.requestFocus();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        quranState.maybeWhen(
                          orElse: () => const SizedBox(),
                          data: (data) {
                            return FocusableActionDetector(
                              focusNode: shuffleFocusNode,
                              actions: <Type, Action<Intent>>{
                                ActivateIntent: CallbackAction<ActivateIntent>(
                                  onInvoke: (ActivateIntent intent) {
                                    ref.read(quranPlayerNotifierProvider.notifier).shuffle();
                                    return null;
                                  },
                                ),
                              },
                              onFocusChange: (hasFocus) {
                                setState(() {});
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: shuffleFocusNode.hasFocus ? theme.primaryColor : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: SvgPicture.asset(
                                    R.ASSETS_ICON_SHUFFLE_SVG,
                                    color: data.isShuffled || shuffleFocusNode.hasFocus
                                        ? Colors.white
                                        : Colors.grey[800],
                                    matchTextDirection: true,
                                    width: 6.w,
                                  ),
                                  iconSize: 8.w,
                                  onPressed: () {
                                    ref.read(quranPlayerNotifierProvider.notifier).shuffle();
                                    shuffleFocusNode.requestFocus();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  FocusableActionDetector(
                    focusNode: leftFocusNode,
                    shortcuts: {
                      LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                    },
                    actions: {
                      ActivateIntent: CallbackAction<ActivateIntent>(
                        onInvoke: (intent) {
                          final notifier = ref.read(quranPlayerNotifierProvider.notifier);
                          if (directionality == TextDirection.ltr) {
                            notifier.seekToPrevious();
                          } else {
                            notifier.seekToNext();
                          }
                          return null;
                        },
                      ),
                    },
                    onFocusChange: (hasFocus) {
                      setState(() {});
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: leftFocusNode.hasFocus ? theme.primaryColor : Colors.transparent,
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
                          leftFocusNode.requestFocus();

                          final notifier = ref.read(quranPlayerNotifierProvider.notifier);
                          if (directionality == TextDirection.ltr) {
                            notifier.seekToPrevious();
                          } else {
                            notifier.seekToNext();
                          }
                        },
                      ),
                    ),
                  ),
                  FocusableActionDetector(
                    shortcuts: {
                      LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                    },
                    actions: {
                      ActivateIntent: CallbackAction<ActivateIntent>(
                        onInvoke: (intent) {
                          final notifier = ref.read(quranPlayerNotifierProvider.notifier);
                          if (widget.isPlaying) {
                            notifier.pause();
                          } else {
                            notifier.play();
                          }
                          return null;
                        },
                      ),
                    },
                    focusNode: playFocusNode,
                    onFocusChange: (hasFocus) {
                      setState(() {});
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: playFocusNode.hasFocus ? theme.primaryColor : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: widget.isPlaying
                            ? SvgPicture.asset(
                                R.ASSETS_ICON_PAUSE_SVG,
                                color: Colors.white,
                              )
                            : Transform.rotate(
                                angle: directionality == TextDirection.rtl ? math.pi : 0,
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 8.w,
                                ),
                              ),
                        iconSize: 10.w,
                        onPressed: () {
                          final notifier = ref.read(quranPlayerNotifierProvider.notifier);
                          if (widget.isPlaying) {
                            notifier.pause();
                          } else {
                            notifier.play();
                          }
                          playFocusNode.requestFocus();
                        },
                      ),
                    ),
                  ),
                  FocusableActionDetector(
                    focusNode: rightFocusNode,
                    onFocusChange: (hasFocus) {
                      setState(() {});
                    },
                    shortcuts: {
                      LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                    },
                    actions: {
                      ActivateIntent: CallbackAction<ActivateIntent>(
                        onInvoke: (intent) {
                          final notifier = ref.read(quranPlayerNotifierProvider.notifier);
                          if (directionality == TextDirection.ltr) {
                            notifier.seekToNext();
                          } else {
                            notifier.seekToPrevious();
                          }
                          return null;
                        },
                      ),
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: rightFocusNode.hasFocus ? theme.primaryColor : Colors.transparent,
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
                          rightFocusNode.requestFocus();

                          final notifier = ref.read(quranPlayerNotifierProvider.notifier);
                          if (directionality == TextDirection.ltr) {
                            notifier.seekToNext();
                          } else {
                            notifier.seekToPrevious();
                          }
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FocusScope(
                          node: volumeFocusNode,
                          onKeyEvent: (node, event) {
                            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                              sliderFocusNode.requestFocus();
                              return KeyEventResult.handled;
                            }
                            else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                              playFocusNode.requestFocus();
                              return KeyEventResult.handled;
                            }
                            else if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
                                !quranState.value!.isVolumeOpened
                            ) {
                              playFocusNode.requestFocus();
                              return KeyEventResult.handled;
                            }
                            return KeyEventResult.ignored;
                          },
                          child: Consumer(
                            builder: (context, ref, child) {

                              final playerState = ref.watch(quranPlayerNotifierProvider);
                              return playerState.when(
                                data: (state) {
                                  if(state.isVolumeOpened) {
                                    if(!volumeFocusNode.hasFocus){
                                      ref.read(quranPlayerNotifierProvider.notifier).closeVolume();
                                    }
                                    return Slider(
                                      value: state.volume,
                                      onChanged: (newValue) {
                                        ref.read(quranPlayerNotifierProvider.notifier).setVolume(newValue);
                                      },
                                      min: 0.0,
                                      max: 1.0,
                                    );
                                  }
                                  else{
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: volumeFocusNode.hasFocus ? theme.primaryColor : Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon:  Icon(Icons.volume_down,size: 35,),
                                        onPressed: () {
                                          ref.read(quranPlayerNotifierProvider.notifier).toggleVolume();                                      },
                                      ),
                                    );
                                  }
                                },
                                loading: () => CircularProgressIndicator(),
                                error: (error, stack) => Text('Error: $error'),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
