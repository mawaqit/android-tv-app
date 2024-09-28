import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fpdart/fpdart.dart';
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
  final MoshafModel selectedMoshaf;
  final String reciterId;

  const SurahSelectionScreen({
    super.key,
    required this.selectedMoshaf,
    required this.reciterId,
  });

  @override
  ConsumerState createState() => _SurahSelectionScreenState();
}

class _SurahSelectionScreenState extends ConsumerState<SurahSelectionScreen> {
  int selectedIndex = 0;
  final int _crossAxisCount = 4;
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quranPlayerNotifierProvider.notifier).getDownloadedSuwarByReciterAndRiwayah(
            reciterId: widget.reciterId,
            moshafId: widget.selectedMoshaf.id.toString(),
          );
    });
  }

  @override
  void dispose() {
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

  void _debouncedNavigation(BuildContext context, SurahModel surah, List<SurahModel> suwar) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!_isNavigating) {
        _isNavigating = true;
        _navigateToQuranPlayerScreen(context, surah, suwar);
      }
    });
  }

  void _navigateToQuranPlayerScreen(BuildContext context, SurahModel surah, List<SurahModel> suwar) {
    ref.read(quranPlayerNotifierProvider.notifier).initialize(
          moshaf: widget.selectedMoshaf,
          surah: surah,
          suwar: suwar,
          reciterId: widget.reciterId,
        );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuranPlayerScreen(),
      ),
    ).then((_) {
      _isNavigating = false;
    });
  }

  String _getKey() {
    return "${widget.reciterId}:${widget.selectedMoshaf.id.toString()}";
  }

  @override
  Widget build(BuildContext context) {
    final downloadNotifierParameter = DownloadStateProviderParameter(
      reciterId: widget.reciterId,
      moshafId: widget.selectedMoshaf.id.toString(),
    );

    final quranState = ref.watch(quranNotifierProvider);
    ref.listen<DownloadAudioQuranState>(downloadStateProvider(downloadNotifierParameter), (previous, next) {
      if (next.downloadStatus == DownloadStatus.completed) {
        showToast(S.of(context).downloadAllSuwarSuccessfully);
        ref
            .read(
              downloadStateProvider(downloadNotifierParameter).notifier,
            )
            .resetDownloadStatus();
      } else if (next.downloadStatus == DownloadStatus.noNewDownloads) {
        showToast(S.of(context).noSuwarDownload);
        ref.read(downloadStateProvider(downloadNotifierParameter).notifier).resetDownloadStatus();
      }
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF28262F),
        elevation: 0,
        actions: [
          IconButton(
            splashRadius: 12.sp,
            iconSize: 14.sp,
            focusColor: Theme.of(context).primaryColor,
            onPressed: ref
                        .watch(
                          downloadStateProvider(downloadNotifierParameter),
                        )
                        .downloadStatus !=
                    DownloadStatus.downloading
                ? () async {
                    await ref.read(connectivityProvider.notifier).checkInternetConnection();
                    if (ref.read(connectivityProvider).value == ConnectivityStatus.connected) {
                      quranState.whenOrNull(
                        data: (data) {
                          ref.read(quranPlayerNotifierProvider.notifier).downloadAllSuwar(
                                reciterId: widget.reciterId.toString(),
                                moshaf: widget.selectedMoshaf,
                                moshafId: widget.selectedMoshaf.id.toString(),
                                suwar: data.suwar,
                              );
                        },
                      );
                    } else {
                      showToast(S.of(context).connectDownloadQuran);
                    }
                  }
                : null,
            icon: Icon(
              Icons.download,
            ),
          )
        ],
        leading: IconButton(
          splashRadius: 12.sp,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(R.ASSETS_BACKGROUNDS_QURAN_BACKGROUND_PNG),
            fit: BoxFit.cover,
          ),
          gradient: ThemeNotifier.quranBackground(),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // IconButton(
                  //   icon: Icon(Icons.arrow_back),
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //   },
                  // ),
                  // Material(
                  //   borderRadius: BorderRadius.circular(25.sp),
                  //   color: Colors.white.withOpacity(0.2),
                  //   child: InkWell(
                  //     onTap: ref.watch(downloadStateProvider).downloadStatus != DownloadStatus.downloading
                  //         ? () async {
                  //             await ref.read(connectivityProvider.notifier).checkInternetConnection();
                  //             if (ref.read(connectivityProvider).value == ConnectivityStatus.connected) {
                  //               quranState.whenOrNull(
                  //                 data: (data) {
                  //                   ref.read(quranPlayerNotifierProvider.notifier).downloadAllSuwar(
                  //                         reciterId: widget.reciterId.toString(),
                  //                         moshaf: widget.selectedMoshaf,
                  //                         moshafId: widget.selectedMoshaf.id.toString(),
                  //                         suwar: data.suwar,
                  //                       );
                  //                 },
                  //               );
                  //             } else {
                  //               showToast(S.of(context).connectDownloadQuran);
                  //             }
                  //           }
                  //         : null,
                  //     focusColor: Theme.of(context).primaryColor,
                  //     child: Icon(
                  //       Icons.download,
                  //       size: 22.sp,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              SizedBox(height: 10),
              Expanded(
                child: quranState.when(
                  data: (data) {
                    return GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      controller: _scrollController,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _crossAxisCount,
                        childAspectRatio: 1.8,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: data.suwar.length,
                      itemBuilder: (context, index) {
                        final downloadState = ref.watch(
                          downloadStateProvider(downloadNotifierParameter),
                        );
                        final reciterMoshafState = downloadState;

                        final isDownloaded = reciterMoshafState.downloadedSuwar.contains(data.suwar[index].id);
                        final downloadProgress = reciterMoshafState.downloadingSuwar
                            .firstWhere(
                              (info) => info.surahId == data.suwar[index].id,
                              orElse: () => SurahDownloadInfo(surahId: data.suwar[index].id, progress: 0.0),
                            )
                            .progress;
                        return SurahCard(
                          index: index,
                          isDownloaded: isDownloaded,
                          downloadProgress: downloadProgress,
                          onDownloadTap: !isDownloaded
                              ? () async {
                                  await ref.read(connectivityProvider.notifier).checkInternetConnection();
                                  if (ref.read(connectivityProvider).value == ConnectivityStatus.connected) {
                                    ref.read(quranPlayerNotifierProvider.notifier).downloadAudio(
                                          reciterId: widget.reciterId,
                                          moshafId: widget.selectedMoshaf.id.toString(),
                                          surahId: data.suwar[index].id,
                                          url: data.suwar[index].getSurahUrl(widget.selectedMoshaf.server),
                                        );
                                  } else {
                                    showToast(S.of(context).connectDownloadQuran);
                                  }
                                }
                              : null,
                          surahName: data.suwar[index].name,
                          surahNumber: data.suwar[index].id,
                          onTap: () async {
                            await ref.read(connectivityProvider.notifier).checkInternetConnection();
                            setState(() {
                              selectedIndex = index;
                            });
                            if ((ref.read(connectivityProvider).hasValue &&
                                    ref.read(connectivityProvider).value == ConnectivityStatus.connected) ||
                                isDownloaded) {
                              _debouncedNavigation(context, data.suwar[index], data.suwar);
                            } else {
                              showToast(S.of(context).playInOnlineModeQuran);
                            }
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
      ),
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
}

final navigateIntoNewPageProvider = StateProvider.autoDispose<bool>((ref) => false);
