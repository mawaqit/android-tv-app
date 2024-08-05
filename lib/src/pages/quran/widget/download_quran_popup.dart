import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_state.dart';

class DownloadQuranPopup extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  void dispose() {
    ref.read(downloadQuranNotifierProvider.notifier).cancelDownload();
  }

  Future<void> showDownloadQuranAlertDialog(BuildContext context) async {
    await ref.read(downloadQuranNotifierProvider.notifier).checkForUpdate();

    final state = ref.read(downloadQuranNotifierProvider);
    final isNoUpdate = state.when(
      data: (data) {
        if (data is NoUpdate) {
          return false;
        } else {
          return true;
        }
      },
      error: (err, stack) => false,
      loading: () => false,
    );
    if (isNoUpdate) {
      final shouldDownload = await showFirstTimePopup(context);
      if (shouldDownload) {
        state.when(
          data: (data) async {
            if (data is UpdateAvailable) {
              ref.read(downloadQuranNotifierProvider.notifier).download();
              return progressQuran(context);
            } else {
              await _alreadyUpdatedVersion(context);
            }
          },
          error: (err, stack) => _buildErrorPopup(context, err),
          loading: () => CircularProgressIndicator(),
        );
      } else {
        Navigator.pop(context);
      }
    }
  }

  Future<void> progressQuran(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, _) {
            final downloadQuranState = ref.watch(downloadQuranNotifierProvider);
            return downloadQuranState.when(
              data: (state) {
                if (state is Downloading) {
                  return _buildDownloadingPopup(context, state.progress);
                } else if (state is Extracting) {
                  return _buildExtractingPopup(context, state.progress);
                } else if (state is Success) {
                  return _buildSuccessPopup(context, state.version);
                } else {
                  return _buildInitialPopup(
                    context,
                  );
                }
              },
              loading: () => _buildCheckingPopup(context),
              error: (error, stackTrace) => _buildErrorPopup(context, error),
            );
          },
        );
      },
    );
  }

  Future<bool> showFirstTimePopup(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).downloadQuran),
          content: Text(S.of(context).askDownloadQuran),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(S.of(context).cancel),
            ),
            TextButton(
              autofocus: true,
              onPressed: () => Navigator.pop(context, true),
              child: Text(S.of(context).download),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCheckingPopup(BuildContext context) {
    return AlertDialog(
      alignment: Alignment.center,
      content: CircularProgressIndicator(
        color: Theme.of(context).primaryColor,
      ),
      actions: [
        TextButton(
          autofocus: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(S.of(context).cancel),
        ),
      ],
    );
  }

  Widget _buildDownloadingPopup(BuildContext context, double progress) {
    return AlertDialog(
      title: Text(S.of(context).downloadingQuran),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: progress / 100,
          ),
          const SizedBox(height: 8),
          Text('${progress.toStringAsFixed(2)}%'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(downloadQuranNotifierProvider.notifier).cancelDownload();
            Navigator.pop(context);
          },
          child: Text(S.of(context).cancel),
        ),
      ],
    );
  }

  Widget _buildInitialPopup(BuildContext context) {
    final l10n = S.of(context);
    return AlertDialog(
      title: Text(l10n.checkingForUpdates),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 8),
          Text('${l10n.checkingForUpdates}...'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(S.of(context).cancel),
        ),
      ],
    );
  }

  Widget _buildExtractingPopup(BuildContext context, double progress) {
    return AlertDialog(
      title: Text(S.of(context).extractingQuran),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: progress / 100,
          ),
          const SizedBox(height: 8),
          Text('${progress.toStringAsFixed(2)}%'),
        ],
      ),
    );
  }

  Widget _buildSuccessPopup(BuildContext context, String version) {
    return AlertDialog(
      title: Text(S.of(context).quranIsUpdated),
      content: Text(S.of(context).quranUpdatedVersion(version)),
      actions: [
        TextButton(
          autofocus: true,
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).ok),
        ),
      ],
    );
  }

  Widget _buildErrorPopup(BuildContext context, Object error) {
    final l10n = S.of(context);
    return AlertDialog(
      title: Text(S.of(context).error),
      content: Text(l10n.error),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).ok),
        ),
      ],
    );
  }

  Future<void> _alreadyUpdatedVersion(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).quranIsUpdated),
          content: Text(S.of(context).quranIsAlreadyDownloaded),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.of(context).ok),
            ),
          ],
        );
      },
    );
  }
}

final downloadQuranPopUpProvider = AsyncNotifierProvider(DownloadQuranPopup.new);
