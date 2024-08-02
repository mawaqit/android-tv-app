import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_state.dart';

Future<void> showDownloadQuranAlertDialog(BuildContext context, WidgetRef ref) async {
  final isFirstTime = true;
  
  if (!context.mounted) return;

  await ref.read(downloadQuranNotifierProvider.notifier).checkForUpdate();
  
  if (!context.mounted) return;

  final state = ref.watch(downloadQuranNotifierProvider);

  final isNoUpdate = state.when(
    data: (data) => data is! NoUpdate,
    error: (err, stack) => false,
    loading: () => false,
  );

  if (isNoUpdate && isFirstTime && context.mounted) {
    final shouldDownload = await showFirstTimePopup(context);
    
    if (!context.mounted) return;

    if (shouldDownload) {
      await state.when(
        data: (data) async {
          if (data is UpdateAvailable) {
            ref.read(downloadQuranNotifierProvider.notifier).download();
            if (context.mounted) {
              return progressQuran(context, ref);
            }
          } else if (context.mounted) {
            await _alreadyUpdatedVersion(context, ref);
          }
        },
        error: (err, stack) {
          if (context.mounted) {
            _buildErrorPopup(context, err);
          }
        },
        loading: () {
          if (context.mounted) {
            return CircularProgressIndicator();
          }
        },
      );
    } else if (context.mounted) {
      Navigator.pop(context);
    }
  }
}

Future<void> progressQuran(BuildContext context, WidgetRef ref) async {
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
                return _buildDownloadingPopup(context, state.progress, ref);
              } else if (state is Extracting) {
                return _buildExtractingPopup(context, state.progress);
              } else if (state is Success) {
                return _buildSuccessPopup(context, state.version);
              } else {
                return _buildInitialPopup(context, ref);
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
    // barrierColor: Colors.transparent,
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
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(S.of(context).cancel),
      ),
    ],
  );
}

Widget _buildDownloadingPopup(BuildContext context, double progress, WidgetRef ref) {
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

Widget _buildInitialPopup(BuildContext context, WidgetRef ref) {
  return AlertDialog(
    title: const Text('Checking for Updates'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 8),
        const Text('Checking for updates...'),
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
        onPressed: () => Navigator.pop(context),
        child: Text(S.of(context).ok),
      ),
    ],
  );
}

Widget _buildErrorPopup(BuildContext context, Object error) {
  return AlertDialog(
    title: Text(S.of(context).error),
    content: Text('An error occurred: $error'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(S.of(context).ok),
      ),
    ],
  );
}

Future<void> _alreadyUpdatedVersion(BuildContext context, WidgetRef ref) async {
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
