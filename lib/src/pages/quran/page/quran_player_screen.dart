import 'dart:math' as math;
import 'package:collection/collection.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fpdart/fpdart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/surah_model.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/pages/quran/page/surah_selection_screen.dart';
import 'package:mawaqit/src/pages/quran/widget/quran_player/seek_bar.dart';
import 'package:mawaqit/src/state_management/quran/recite/download_audio_quran/download_audio_quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/recite/download_audio_quran/download_audio_quran_state.dart';
import 'package:mawaqit/src/state_management/quran/recite/quran_audio_player_notifier.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:rxdart/rxdart.dart' as rxdart;
import 'package:mawaqit/const/resource.dart';
import 'package:sizer/sizer.dart';
import 'package:mawaqit/src/state_management/quran/recite/quran_audio_player_state.dart';
import 'package:mawaqit/src/pages/quran/widget/quran_background.dart';

class QuranPlayerScreen extends ConsumerStatefulWidget {
  final String reciterId;
  final MoshafModel selectedMoshaf;
  final SurahModel surah;

  const QuranPlayerScreen({
    super.key,
    required this.reciterId,
    required this.selectedMoshaf,
    required this.surah,
  });

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
        },
      );

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
          leading: InkWell(
            borderRadius: BorderRadius.circular(20.sp),
            child: Icon(Icons.arrow_back),
            onTap: () {
              ref.read(quranPlayerNotifierProvider.notifier).stop();
              Navigator.of(context).pop();
            },
          ),
        ),
        screen: quranPlayerState.maybeWhen(
          orElse: () {
            return const SizedBox();
          },
          data: (quranPlayerState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // const _BackgroundFilter(),
                Flexible(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: buildReciterImage(),
                  ),
                ),
                Flexible(
                  flex: 9,
                  child: _QuranPlayer(
                    backButtonFocusNode: backButtonFocusNode,
                    isPlaying: quranPlayerState.playerState == AudioPlayerState.playing,
                    surahName: quranPlayerState.surahName,
                    surahType: quranPlayerState.reciterName,
                    seekBarDataStream: _seekBarDataStream,
                    onFocusBackButton: () => backButtonFocusNode.requestFocus(),
                    selectedMoshaf: widget.selectedMoshaf,
                    reciterId: widget.reciterId,
                    surah: widget.surah,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  ClipOval buildReciterImage() {
    return ClipOval(
      child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: FastCachedImage(
              url: '${QuranConstant.kQuranReciterImagesBaseUrl}${widget.reciterId}.jpg',
              fit: BoxFit.fitWidth,
              loadingBuilder: (context, progress) => Container(color: Colors.transparent),
              errorBuilder: (context, error, stackTrace) => _buildOfflineImage())),
    );
  }
}

Widget _buildOfflineImage() {
  return Center(
    child: Container(
      width: 24.w,
      height: 24.w,
      padding: EdgeInsets.only(bottom: 2.h),
      child: Image.asset(
        R.ASSETS_SVG_RECITER_ICON_PNG,
        fit: BoxFit.contain,
      ),
    ),
  );
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
    required this.selectedMoshaf,
    required this.reciterId,
    required this.surah,
  }) : _seekBarDataStream = seekBarDataStream;

  final VoidCallback onFocusBackButton;
  final String surahName;
  final String surahType;
  final bool isPlaying;
  final MoshafModel selectedMoshaf;
  final String reciterId;
  final SurahModel surah;
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
  late final FocusNode downloadFocusNode;

  Color _sliderThumbColor = Colors.white;
  Color _volumeSliderThumbColor = Colors.white;

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
    downloadFocusNode = FocusNode();
    sliderFocusNode.addListener(_setSliderThumbColor);
    volumeFocusNode.addListener(_setVolumeSliderThumbColor);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      playFocusNode.requestFocus();
    });
  }

  _setSliderThumbColor() {
    setState(() {
      _sliderThumbColor = sliderFocusNode.hasFocus ? Color(0xFF490094) : Colors.white;
    });
  }

  _setVolumeSliderThumbColor() {
    setState(() {
      _volumeSliderThumbColor = volumeFocusNode.hasFocus ? Color(0xFF490094) : Colors.white;
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
    downloadFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quranState = ref.watch(quranPlayerNotifierProvider);
    final directionality = Directionality.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(1.h),
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add reciter's image here
            // SizedBox(height: 1.h),
            SizedBox(
              width: 80.w,
              child: Text(
                widget.surahName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: 80.w,
              child: Text(
                widget.surahType,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[400],
                ),
              ),
            ),
            SizedBox(height: 1.h),
            buildDownloadButton(),
            buildSlider(),
            SizedBox(height: 2.h),
            buildBottom(quranState, theme, directionality, context),
          ],
        ),
      ),
    );
  }

  Row buildDownloadButton() {
    return Row(
      children: [
        Spacer(),
        Consumer(
          builder: (context, ref, child) {
            final quranPlayer = ref.watch(
              downloadStateProvider(
                DownloadStateProviderParameter(
                  reciterId: widget.reciterId,
                  moshafId: widget.selectedMoshaf.id.toString(),
                ),
              ),
            );

            final isDownloaded = quranPlayer.downloadedSuwar.contains(widget.surah.id);

            final findFirstDownloadedSurah = quranPlayer.downloadingSuwar.firstWhereOrNull(
              (element) => element.surahId == widget.surah.id,
            );
            return downloadingWidget(
              isDownloaded,
              Option.fromNullable(findFirstDownloadedSurah),
            );
          },
        ),
      ],
    );
  }

  FocusTraversalOrder buildBottom(AsyncValue<QuranAudioPlayerState> quranState, ThemeData theme,
      TextDirection directionality, BuildContext context) {
    return FocusTraversalOrder(
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
                      shortcuts: {
                        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                      },
                      actions: {
                        ActivateIntent: CallbackAction<ActivateIntent>(
                          onInvoke: (ActivateIntent intent) {
                            ref.read(quranPlayerNotifierProvider.notifier).repeat();
                            return null;
                          },
                        ),
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: repeatFocusNode.hasFocus ? theme.primaryColor : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          height: 30.sp,
                          width: 30.sp,
                          child: IconButton(
                            iconSize: 14.sp,
                            icon: FaIcon(
                              FontAwesomeIcons.repeat,
                              color: data.isRepeating || repeatFocusNode.hasFocus ? Colors.white : Colors.grey[800],
                            ),
                            onPressed: () {
                              ref.read(quranPlayerNotifierProvider.notifier).repeat();
                              repeatFocusNode.requestFocus();
                            },
                          ),
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
                        child: Container(
                          height: 30.sp,
                          width: 30.sp,
                          child: IconButton(
                            iconSize: 14.sp,
                            icon: FaIcon(
                              FontAwesomeIcons.shuffle,
                              color: data.isShuffled || shuffleFocusNode.hasFocus ? Colors.white : Colors.grey[800],
                            ),
                            onPressed: () {
                              ref.read(quranPlayerNotifierProvider.notifier).shuffle();
                              shuffleFocusNode.requestFocus();
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            height: 30.sp,
            width: 30.sp,
            child: InkWell(
              child: Builder(
                builder: (context) {
                  final isFocused = Focus.of(context).hasFocus;
                  return Container(
                    decoration: BoxDecoration(
                      color: isFocused ? theme.primaryColor : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      iconSize: 14.sp,
                      icon: FaIcon(
                        directionality != TextDirection.ltr ? FontAwesomeIcons.forward : FontAwesomeIcons.backward,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        final notifier = ref.read(quranPlayerNotifierProvider.notifier);
                        notifier.seekToPrevious();
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            height: 30.sp,
            width: 30.sp,
            child: InkWell(
              child: Builder(
                builder: (context) {
                  final isFocused = Focus.of(context).hasFocus;
                  final isRTL = Directionality.of(context) == TextDirection.rtl;

                  return Container(
                    decoration: BoxDecoration(
                      color: isFocused ? theme.primaryColor : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      iconSize: 14.sp,
                      icon: Transform.rotate(
                        angle: isRTL && !widget.isPlaying ? math.pi : 0,
                        child: FaIcon(
                          widget.isPlaying ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        final notifier = ref.read(quranPlayerNotifierProvider.notifier);
                        if (widget.isPlaying) {
                          notifier.pause();
                        } else {
                          notifier.play();
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            height: 30.sp,
            width: 30.sp,
            child: InkWell(
              child: Builder(
                builder: (context) {
                  final isFocused = Focus.of(context).hasFocus;
                  return Container(
                    decoration: BoxDecoration(
                      color: isFocused ? theme.primaryColor : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      iconSize: 14.sp,
                      icon: FaIcon(
                        directionality == TextDirection.ltr ? FontAwesomeIcons.forward : FontAwesomeIcons.backward,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        final notifier = ref.read(quranPlayerNotifierProvider.notifier);
                        notifier.seekToNext();
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FocusableActionDetector(
                  focusNode: volumeFocusNode,
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) {
                      ref.read(quranPlayerNotifierProvider.notifier).closeVolume();
                    }
                    setState(() {});
                  },
                  shortcuts: {
                    LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                    LogicalKeySet(LogicalKeyboardKey.arrowLeft): const DirectionalFocusIntent(TraversalDirection.left),
                    LogicalKeySet(LogicalKeyboardKey.arrowUp): const DirectionalFocusIntent(TraversalDirection.up),
                    LogicalKeySet(LogicalKeyboardKey.arrowDown): const DirectionalFocusIntent(TraversalDirection.down),
                    LogicalKeySet(LogicalKeyboardKey.arrowRight):
                        const DirectionalFocusIntent(TraversalDirection.right),
                  },
                  actions: {
                    DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
                      onInvoke: (DirectionalFocusIntent intent) {
                        final quranNotifier = ref.read(quranPlayerNotifierProvider.notifier);
                        final isRTL = Directionality.of(context) == TextDirection.rtl;
                        quranState.maybeWhen(
                            orElse: () {},
                            data: (state) {
                              if (state.isVolumeOpened) {
                                switch (intent.direction) {
                                  case TraversalDirection.left:
                                    if (isRTL) {
                                      quranNotifier.setVolume(state.volume + 0.1);
                                    } else {
                                      quranNotifier.setVolume(state.volume - 0.1);
                                    }
                                    break;
                                  case TraversalDirection.right:
                                    if (isRTL) {
                                      quranNotifier.setVolume(state.volume - 0.1);
                                    } else {
                                      quranNotifier.setVolume(state.volume + 0.1);
                                    }
                                    break;
                                  case TraversalDirection.up:
                                    sliderFocusNode.requestFocus();
                                    break;
                                  case TraversalDirection.down:
                                    playFocusNode.requestFocus();
                                    break;
                                }
                              } else {
                                switch (intent.direction) {
                                  case TraversalDirection.up:
                                    sliderFocusNode.requestFocus();
                                    break;
                                  case TraversalDirection.down:
                                    playFocusNode.requestFocus();
                                    break;
                                  case TraversalDirection.left:
                                    if (!isRTL) {
                                      playFocusNode.requestFocus();
                                    }
                                    break;
                                  case TraversalDirection.right:
                                    if (isRTL) {
                                      playFocusNode.requestFocus();
                                    }
                                    break;
                                }
                              }
                            });
                        return null;
                      },
                    ),
                    ActivateIntent: CallbackAction<ActivateIntent>(
                      onInvoke: (ActivateIntent intent) {
                        final quranNotifier = ref.read(quranPlayerNotifierProvider.notifier);
                        quranNotifier.toggleVolume();
                        return null;
                      },
                    ),
                  },
                  child: Consumer(
                    builder: (context, ref, child) {
                      final playerState = ref.watch(quranPlayerNotifierProvider);
                      final isRTL = Directionality.of(context) == TextDirection.rtl;
                      return playerState.when(
                        data: (state) {
                          if (state.isVolumeOpened && volumeFocusNode.hasFocus) {
                            return Slider(
                              thumbColor: _volumeSliderThumbColor,
                              value: state.volume,
                              onChanged: (newValue) {
                                ref.read(quranPlayerNotifierProvider.notifier).setVolume(newValue);
                              },
                              min: 0.0,
                              max: 1.0,
                            );
                          } else {
                            return Container(
                              height: 30.sp,
                              width: 30.sp,
                              decoration: BoxDecoration(
                                color: volumeFocusNode.hasFocus ? theme.primaryColor : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                iconSize: 14.sp,
                                icon: Transform.scale(
                                  scaleX: isRTL ? -1 : 1,
                                  child: FaIcon(
                                    FontAwesomeIcons.volumeDown,
                                    color: volumeFocusNode.hasFocus ? Colors.white : _volumeSliderThumbColor,
                                  ),
                                ),
                                onPressed: () {
                                  volumeFocusNode.requestFocus();
                                  ref.read(quranPlayerNotifierProvider.notifier).toggleVolume();
                                },
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
    );
  }

  StreamBuilder<SeekBarData> buildSlider() {
    return StreamBuilder<SeekBarData>(
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
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: 7.vwr,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: 10.vwr,
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
    );
  }

  Widget downloadingWidget(bool isDownloaded, Option<SurahDownloadInfo> downloadProgress) {
    return downloadProgress.fold(
      () => InkWell(
        focusColor: Colors.grey,
        child: Builder(
          builder: (context) {
            final isFocused = Focus.of(context).hasFocus;
            return Container(
              height: 30.sp,
              width: 30.sp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFocused ? Color(0xFF490094) : Colors.transparent,
              ),
              child: IconButton(
                iconSize: 14.sp,
                icon: FaIcon(
                  isDownloaded ? FontAwesomeIcons.check : FontAwesomeIcons.download,
                  color: Colors.white,
                ),
                onPressed: isDownloaded
                    ? null
                    : () async {
                        await ref.read(quranPlayerNotifierProvider.notifier).downloadAudio(
                              reciterId: widget.reciterId,
                              moshafId: widget.selectedMoshaf.id.toString(),
                              surahId: widget.surah.id,
                              url: widget.surah.getSurahUrl(
                                widget.selectedMoshaf.server,
                              ),
                            );
                      },
              ),
            );
          },
        ),
      ),
      (t) {
        return CircularPercentIndicator(
          radius: 15.sp,
          lineWidth: 3.sp,
          percent: t.progress,
          progressColor: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.3),
          center: Text(
            '${(t.progress * 100).toInt()}%',
            style: TextStyle(color: Colors.white, fontSize: 8.sp),
          ),
        );
      },
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
