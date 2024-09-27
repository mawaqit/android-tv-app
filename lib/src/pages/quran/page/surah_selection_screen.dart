import 'dart:async';
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
  Timer? _debounceTimer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    ref.read(quranPlayerNotifierProvider.notifier).getDownloadedSuwarByReciterAndRiwayah(
          reciterId: widget.reciterId.toString(),
          riwayahId: widget.riwayatId.toString(),
        );
  }

  @override
  void dispose() {
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
    final moshaf = ref.read(reciteNotifierProvider).maybeWhen(
          orElse: () => null,
          data: (data) => data.selectedMoshaf,
        );
    ref.read(quranPlayerNotifierProvider.notifier).initialize(
          moshaf: moshaf!,
          surah: surah,
          reciterId: widget.reciterId.toString(),
          suwar: suwar,
          riwayahId: widget.riwayatId.toString(),
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
    return "${widget.reciterId}:${widget.riwayatId}";
  }

  @override
  Widget build(BuildContext context) {
    final quranState = ref.watch(quranNotifierProvider);
    ref.listen<DownloadAudioQuranState>(downloadStateProvider, (previous, next) {
      if (next.downloadStatus == DownloadStatus.completed) {
        showToast(S.of(context).downloadAllSuwarSuccessfully);
        ref.read(downloadStateProvider.notifier).resetDownloadStatus();
      } else if (next.downloadStatus == DownloadStatus.noNewDownloads) {
        showToast(S.of(context).noSuwarDownload);
        ref.read(downloadStateProvider.notifier).resetDownloadStatus();
      }
    });
    return Scaffold(
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
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    focusColor: Colors.green,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    onPressed: ref.watch(downloadStateProvider).downloadStatus != DownloadStatus.downloading
                        ? () async {}
                        : null,
                    icon: Icon(
                      Icons.download,
                      size: 16.sp,
                    ),
                  ),
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
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: data.suwar.length,
                      itemBuilder: (context, index) {
                        final isDownloaded = ref.watch(
                          downloadStateProvider.select(
                            (state) => state.downloadedSuwar[_getKey()]?.contains(data.suwar[index].id) ?? false,
                          ),
                        );
                        return SurahCard(
                          index: index,
                          isDownloaded: isDownloaded,
                          downloadProgress: ref.watch(
                            downloadStateProvider.select(
                              (state) => state.downloadProgress[_getKey()]?[data.suwar[index].id] ?? 0,
                            ),
                          ),
                          onDownloadTap: ref.watch(
                            downloadStateProvider.select(
                              (state) => !(state.downloadedSuwar[_getKey()]?.contains(data.suwar[index].id) ?? false),
                            ),
                          )
                              ? () async {
                                  await ref.read(connectivityProvider.notifier).checkInternetConnection();
                                  if (ref.read(connectivityProvider).value == ConnectivityStatus.connected) {
                                    final moshaf = ref.read(reciteNotifierProvider).maybeWhen(
                                          orElse: () => null,
                                          data: (data) => data.selectedMoshaf,
                                        );
                                    ref.read(quranPlayerNotifierProvider.notifier).downloadAudio(
                                          reciterId: widget.reciterId.toString(),
                                          riwayahId: widget.riwayatId.toString(),
                                          surahId: data.suwar[index].id,
                                          url: data.suwar[index].getSurahUrl(moshaf!.server),
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
