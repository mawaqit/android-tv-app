import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mawaqit/src/domain/model/quran/surah_model.dart';
import 'package:mawaqit/src/pages/quran/widget/quran_background.dart';
import 'package:mawaqit/src/pages/quran/widget/surah_card.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';

import 'package:mawaqit/src/state_management/quran/recite/recite_notifier.dart';
import 'package:shimmer/shimmer.dart';

import 'package:mawaqit/src/state_management/quran/recite/quran_audio_player_notifier.dart';
import 'package:mawaqit/src/pages/quran/page/quran_player_screen.dart';
import 'package:sizer/sizer.dart';

import '../../../../const/resource.dart';
import '../../../../i18n/l10n.dart';
import '../../../domain/model/quran/moshaf_model.dart';
import '../../../domain/model/quran/reciter_model.dart';
import '../../../helpers/connectivity_provider.dart';
import '../../../models/address_model.dart';
import '../../../services/theme_manager.dart';
import '../../../state_management/quran/recite/download_audio_quran/download_audio_quran_notifier.dart';
import '../../../state_management/quran/recite/download_audio_quran/download_audio_quran_state.dart';

class SurahSelectionScreen extends ConsumerStatefulWidget {
  final int reciterId;
  final int riwayatId;

  final ReciterModel reciter;
  final MoshafModel riwayat;

  const SurahSelectionScreen({
    super.key,
    required this.reciterId,
    required this.reciter,
    required this.riwayat,
    required this.riwayatId,
  });

  @override
  ConsumerState createState() => _SurahSelectionScreenState();
}

class _SurahSelectionScreenState extends ConsumerState<SurahSelectionScreen> {
  int selectedIndex = 0;
  final int _crossAxisCount = 4;
  final ScrollController _scrollController = ScrollController();
  late FocusNode _searchFocusNode;
  FocusNode _downloadButtonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    ref
        .read(quranPlayerNotifierProvider.notifier)
        .getDownloadedSuwarByReciterAndRiwayah(
          reciterId: widget.reciterId.toString(),
          riwayahId: widget.riwayatId.toString(),
        );
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    _searchFocusNode = FocusNode();
    _scrollController.dispose();
    super.dispose();
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  String _getKey() {
    return "${widget.reciterId}:${widget.riwayatId}";
  }

  @override
  Widget build(BuildContext context) {
    final quranState = ref.watch(quranNotifierProvider);
    ref.listen<DownloadAudioQuranState>(downloadStateProvider,
        (previous, next) {
      if (next.downloadStatus == DownloadStatus.completed) {
        showToast("download all success");
        ref.read(downloadStateProvider.notifier).resetDownloadStatus();
      } else if (next.downloadStatus == DownloadStatus.noNewDownloads) {
        showToast("no download");
        ref.read(downloadStateProvider.notifier).resetDownloadStatus();
      }
    });
    ref.listen(navigateIntoNewPageProvider, (previous, next) {
      if (next) {
        RawKeyboard.instance.removeListener(_handleKeyEvent);
      } else {
        RawKeyboard.instance.addListener(_handleKeyEvent);
      }
    });
    return Scaffold(
      appBar: AppBar(
/*         backgroundColor: Colors.transparent,
 */ /* elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light, */
        actions: [
          Focus(
            focusNode: _downloadButtonFocusNode,
            child: IconButton(
              onPressed: ref.watch(downloadStateProvider).downloadStatus !=
                      DownloadStatus.downloading
                  ? () async {
                      await ref
                          .read(connectivityProvider.notifier)
                          .checkInternetConnection();
                      if (ref.read(connectivityProvider).value ==
                          ConnectivityStatus.connected) {
                        quranState.whenOrNull(
                          data: (data) {
                            ref
                                .read(quranPlayerNotifierProvider.notifier)
                                .downloadAllSuwar(
                                  reciterId: widget.reciterId.toString(),
                                  riwayahId: widget.riwayatId.toString(),
                                  moshaf: widget.riwayat,
                                  suwar: data.suwar,
                                );
                          },
                        );
                      } else {
                        showToast("connect to download quran");
                      }
                    }
                  : null,
              icon: Icon(
                Icons.download,
                size: 16.sp,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(R.ASSETS_BACKGROUNDS_QURAN_BACKGROUND_PNG),
            fit: BoxFit.cover,
          ),
          gradient: ThemeNotifier.quranBackground(),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ExcludeFocus(
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: quranState.when(
                      data: (data) {
                        return GridView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          controller: _scrollController,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _crossAxisCount,
                            childAspectRatio: 1.8,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: data.suwar.length,
                          itemBuilder: (context, index) {
                            final isDownloaded = ref.watch(
                              downloadStateProvider.select(
                                (state) =>
                                    state.downloadedSuwar[_getKey()]
                                        ?.contains(data.suwar[index].id) ??
                                    false,
                              ),
                            );
                            return SurahCard(
                              isDownloaded: isDownloaded,
                              downloadProgress: ref.watch(
                                downloadStateProvider.select(
                                  (state) =>
                                      state.downloadProgress[_getKey()]
                                          ?[data.suwar[index].id] ??
                                      0,
                                ),
                              ),
                              onDownloadTap: ref.watch(
                                downloadStateProvider.select(
                                  (state) => !(state.downloadedSuwar[_getKey()]
                                          ?.contains(data.suwar[index].id) ??
                                      false),
                                ),
                              )
                                  ? () async {
                                      await ref
                                          .read(connectivityProvider.notifier)
                                          .checkInternetConnection();
                                      if (ref
                                              .read(connectivityProvider)
                                              .value ==
                                          ConnectivityStatus.connected) {
                                        final moshaf = ref
                                            .read(reciteNotifierProvider)
                                            .maybeWhen(
                                              orElse: () => null,
                                              data: (data) =>
                                                  data.selectedMoshaf,
                                            );
                                        ref
                                            .read(quranPlayerNotifierProvider
                                                .notifier)
                                            .downloadAudio(
                                              reciterId:
                                                  widget.reciterId.toString(),
                                              riwayahId:
                                                  widget.riwayatId.toString(),
                                              surahId: data.suwar[index].id,
                                              url: data.suwar[index]
                                                  .getSurahUrl(moshaf!.server),
                                            );
                                      } else {
                                        showToast("connect to download");
                                      }
                                    }
                                  : null,
                              surahName: data.suwar[index].name,
                              surahNumber: data.suwar[index].id,
                              isSelected: index == selectedIndex,
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });
                                final moshaf =
                                    ref.read(reciteNotifierProvider).maybeWhen(
                                          orElse: () => null,
                                          data: (data) => data.selectedMoshaf,
                                        );
                                ref
                                    .read(quranPlayerNotifierProvider.notifier)
                                    .initialize(
                                      moshaf: moshaf!,
                                      surah: data.suwar[index],
                                      suwar: data.suwar,
                                    );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QuranPlayerScreen(),
                                  ),
                                );
                                _scrollToSelectedItem();
                              },
                            );
                          },
                        );
                      },
                      error: (error, stack) {
                        log('Error: $error\n$stack');
                        return Center(
                          child: Text(
                            'Error: $error',
                          ),
                        );
                      },
                      loading: () => _buildShimmerGrid(),
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

  void _handleKeyEvent(RawKeyEvent event) {
    final surahs = ref
        .read(quranNotifierProvider)
        .maybeWhen(orElse: () => [], data: (data) => data.suwar);
    final textDirection = Directionality.of(context);

    if (event is RawKeyDownEvent) {
      log('Key pressed: ${event.logicalKey}');
      if (event.logicalKey == LogicalKeyboardKey.select) {
        _searchFocusNode.requestFocus();
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        setState(() {
          if (textDirection == TextDirection.ltr) {
            selectedIndex = (selectedIndex + 1) % surahs.length;
          } else {
            selectedIndex = (selectedIndex - 1 + surahs.length) % surahs.length;
          }
        });
        _scrollToSelectedItem();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        setState(() {
          if (textDirection == TextDirection.ltr) {
            selectedIndex = (selectedIndex - 1) % surahs.length;
          } else {
            selectedIndex = (selectedIndex + 1 + surahs.length) % surahs.length;
          }
        });
        _scrollToSelectedItem();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (selectedIndex < _crossAxisCount) {
          // _searchFocusNode.requestFocus();
        } else {
          setState(() {
            selectedIndex = (selectedIndex - _crossAxisCount + surahs.length) %
                surahs.length;
          });
          _scrollToSelectedItem();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          selectedIndex = (selectedIndex + _crossAxisCount) % surahs.length;
        });
        _scrollToSelectedItem();
      } else if (event.logicalKey == LogicalKeyboardKey.select) {
        _handleSurahSelection(surahs[selectedIndex]);
      }
    }
  }

  void _handleSurahSelection(SurahModel selectedSurah) {
    final moshaf = ref.read(reciteNotifierProvider).maybeWhen(
          orElse: () => null,
          data: (data) => data.selectedMoshaf,
        );
    final quranState = ref.read(quranNotifierProvider);

    quranState.maybeWhen(
      orElse: () {},
      data: (data) {
        ref.read(quranPlayerNotifierProvider.notifier).initialize(
              moshaf: moshaf!,
              surah: selectedSurah,
              suwar: data.suwar,
            );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(navigateIntoNewPageProvider.notifier).state = true;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuranPlayerScreen(),
            ),
          ).then((_) {
            ref.read(navigateIntoNewPageProvider.notifier).state = false;
          });
        });
      },
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount,
        childAspectRatio: 1.8,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: 20, // Adjust the count as needed
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[800]!,
          highlightColor: Colors.grey[700]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  void _scrollToSelectedItem() {
    final surahs = ref
        .read(quranNotifierProvider)
        .maybeWhen(orElse: () => [], data: (data) => data.suwar);
    final int rowIndex = selectedIndex ~/ _crossAxisCount;
    final double itemHeight = _scrollController.position.maxScrollExtent /
        ((surahs.length - 1) / _crossAxisCount);
    final double targetOffset = rowIndex * itemHeight;
    _scrollController.animateTo(
      targetOffset,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }
}

final navigateIntoNewPageProvider =
    StateProvider.autoDispose<bool>((ref) => false);
