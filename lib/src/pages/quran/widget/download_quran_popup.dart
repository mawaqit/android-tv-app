import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_state.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';

class DownloadQuranPopup extends AsyncNotifier<void> {
  MoshafType selectedMoshafType = MoshafType.hafs;

  @override
  Future<void> build() async {}

  void dispose() {
    ref.read(downloadQuranNotifierProvider.notifier).cancelDownload();
  }

  Future<void> showDownloadQuranAlertDialog(BuildContext context) async {
    final notifier = ref.read(downloadQuranNotifierProvider.notifier);

    await notifier.checkForUpdate(selectedMoshafType);

    final state = ref.read(downloadQuranNotifierProvider);

    if (_isUpdateAvailable(state)) {
      final confirmedDownload = await _requestDownloadConfirmation(context);

      if (confirmedDownload) {
        await _handleDownloadProcess(context, selectedMoshafType);
      } else {
        Navigator.pop(context);
      }
    }
  }

  bool _isUpdateAvailable(AsyncValue state) {
    return state.maybeWhen(
      data: (data) => data is! NoUpdate,
      orElse: () => false,
    );
  }

  Future<bool> _requestDownloadConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return _buildQuranTypeSelectionDialog(context, setState);
          },
        );
      },
    ).then((value) => value ?? false);
  }

  Widget _buildQuranTypeSelectionDialog(
      BuildContext context,
      void Function(VoidCallback fn) setState,
      ) {
    return AlertDialog(
      title: Text(S.of(context).chooseQuranType),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMoshafTypeRadio(
            context,
            title: S.of(context).warsh,
            value: MoshafType.warsh,
            setState: setState,
          ),
          _buildMoshafTypeRadio(
            context,
            title: S.of(context).hafs,
            value: MoshafType.hafs,
            setState: setState,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(S.of(context).cancel),
        ),
        TextButton(
          autofocus: true,
          onPressed: () async {
            Navigator.pop(context, true);
          },
          child: Text(S.of(context).download),
        ),
      ],
    );
  }

  Widget _buildMoshafTypeRadio(
      BuildContext context, {
        required String title,
        required MoshafType value,
        required void Function(VoidCallback fn) setState,
      }) {
    return RadioListTile<MoshafType>(
      title: Text(title),
      value: value,
      autofocus: true,
      groupValue: selectedMoshafType,
      onChanged: (MoshafType? selected) {
        if (selected != null) {
          setState(() {
            selectedMoshafType = selected;
          });
        }
      },
    );
  }

  Future<void> _handleDownloadProcess(
      BuildContext context,
      MoshafType moshafType,
      ) async {
    final notifier = ref.read(downloadQuranNotifierProvider.notifier);

    final state = ref.read(downloadQuranNotifierProvider);

    state.maybeWhen(
      data: (data) async {
        if (data is UpdateAvailable) {
          final shouldDownload = await _showConfirmationDialog(context);
          if (shouldDownload) {
            notifier.download(moshafType);
            await _showDownloadProgressDialog(context);
          }
        } else if (data is NoUpdate) {
          await _alreadyUpdatedVersion(context);
        }
      },
      error: (error, stackTrace) => _buildErrorPopup(context, error),
      orElse: () => _buildErrorPopup(context, 'Unknown error'),
    );
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
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
              autofocus: true,
              child: Text(S.of(context).download),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  Future<void> _showDownloadProgressDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, _) {
            final downloadQuranState = ref.watch(downloadQuranNotifierProvider);
            return downloadQuranState.when(
              data: (state) => _buildStatefulDialog(context, state),
              loading: () => _buildCheckingPopup(context),
              error: (error, stackTrace) => _buildErrorPopup(context, error),
            );
          },
        );
      },
    );
  }

  Widget _buildStatefulDialog(BuildContext context, DownloadQuranState state) {
    if(state is Downloading) {
      return _buildDownloadingPopup(context, state.progress);
    } else if(state is Extracting) {
      return _buildExtractingPopup(context, state.progress);
    } else if(state is Success) {
      return _buildSuccessPopup(context, state.version);
    } else {
      return _buildInitialPopup(context);
    }
  }

  Widget _buildCheckingPopup(BuildContext context) {
    return _buildSimpleDialog(
      context,
      title: S.of(context).checkingForUpdates,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 8),
          Text('${S.of(context).checkingForUpdates}...'),
        ],
      ),
    );
  }

  Widget _buildDownloadingPopup(BuildContext context, double progress) {
    return _buildSimpleDialog(
      context,
      title: S.of(context).downloadingQuran,
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
          autofocus: true,
          child: Text(S.of(context).cancel),
        ),
      ],
    );
  }

  Widget _buildExtractingPopup(BuildContext context, double progress) {
    return _buildSimpleDialog(
      context,
      title: S.of(context).extractingQuran,
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
    return _buildSimpleDialog(
      context,
      title: S.of(context).quranIsUpdated,
      content: Text(S.of(context).quranUpdatedVersion(version)),
    );
  }

  Widget _buildErrorPopup(BuildContext context, Object error) {
    log('Error: $error');
    return _buildSimpleDialog(
      context,
      title: S.of(context).error,
      content: Text(S.of(context).error),
    );
  }

  Widget _buildInitialPopup(BuildContext context) {
    return _buildCheckingPopup(context);
  }

  Future<void> _alreadyUpdatedVersion(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildSimpleDialog(
          context,
          title: S.of(context).quranIsUpdated,
          content: Text(S.of(context).quranIsAlreadyDownloaded),
        );
      },
    );
  }

  Widget _buildSimpleDialog(
      BuildContext context, {
        required String title,
        required Widget content,
        List<Widget>? actions,
      }) {
    return AlertDialog(
      title: Text(title),
      content: content,
      actions: actions ??
          [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.of(context).ok),
            ),
          ],
    );
  }
}

final downloadQuranPopUpProvider = AsyncNotifierProvider(DownloadQuranPopup.new);
