import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/domain/error/quran_exceptions.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_type_model.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_state.dart';
import 'package:mawaqit/src/state_management/quran/reading/moshaf_type_notifier.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';

class DownloadQuranDialog extends ConsumerStatefulWidget {
  const DownloadQuranDialog({super.key});

  @override
  _DownloadQuranDialogState createState() => _DownloadQuranDialogState();
}

class _DownloadQuranDialogState extends ConsumerState<DownloadQuranDialog> {
  MoshafType selectedMoshafType = MoshafType.hafs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdate();
    });
  }

  void _checkForUpdate() {
    final notifier = ref.read(downloadQuranNotifierProvider.notifier);
    // notifier.checkForUpdate(notifier.selectedMoshafType);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(downloadQuranNotifierProvider);
    return state.when(
      data: (data) => _buildContent(context, data),
      loading: () => Container(),
      error: (error, _) => _buildErrorDialog(context, error),
    );
  }

  Widget _buildContent(BuildContext context, DownloadQuranState state) {
    // return Container();
    return switch (state) {
      NeededDownloadedQuran() => _buildChooseDownloadMoshaf(context),
      // UpdateAvailable() => _buildUpdateAvailableDialog(context, state),
      Downloading() => _buildDownloadingDialog(context, state),
      Extracting() => _buildExtractingDialog(context, state),
      Success() => _buildSuccessDialog(context, state),
      CancelDownload() => Container(),
      // NoUpdate() => _buildNoUpdateDialog(context, state),
      _ => Container(),
      // DownloadQuranState() => null,
    };
  }

  Widget _buildUpdateAvailableDialog(BuildContext context, UpdateAvailable state) {
    return AlertDialog(
      title: Text(S.of(context).updateAvailable),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).cancel),
        ),
        TextButton(
          autofocus: true,
          onPressed: () {
            // final notifier = ref.read(downloadQuranNotifierProvider.notifier);
            // notifier.downloadQuran(notifier.selectedMoshafType);
          },
          child: Text(S.of(context).download),
        ),
      ],
    );
  }

  Widget _buildDownloadingDialog(BuildContext context, Downloading state) {
    return AlertDialog(
      title: Text(S.of(context).downloadingQuran),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: state.progress / 100),
          SizedBox(height: 16),
          Text('${state.progress.toStringAsFixed(2)}%'),
        ],
      ),
      actions: [
        TextButton(
          autofocus: true,
          onPressed: () async {
            final notifier = ref.read(downloadQuranNotifierProvider.notifier);
            ref.read(moshafTypeNotifierProvider).maybeWhen(
                  orElse: () {},
                  data: (state) async {
                    state.selectedMoshaf.fold(() {
                      return null;
                    }, (selectedMoshaf) async {
                      await notifier.cancelDownload(selectedMoshaf); // Await cancellation
                      Navigator.pop(context); // Close dialog after cancel completes
                    });
                  },
                );
          },
          child: Text(S.of(context).cancel),
        ),
      ],
    );
  }

  Widget _buildExtractingDialog(BuildContext context, Extracting state) {
    return AlertDialog(
      title: Text(S.of(context).extractingQuran),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: state.progress / 100),
          SizedBox(height: 16),
          Text('${state.progress.toStringAsFixed(2)}%'),
        ],
      ),
    );
  }

  Widget _buildSuccessDialog(BuildContext context, Success state) {
    return AlertDialog(
      title: Text(S.of(context).quranDownloaded),
      actions: [
        TextButton(
          autofocus: true,
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).ok),
        ),
      ],
    );
  }

  Widget _buildNoUpdateDialog(BuildContext context, NoUpdate state) {
    return AlertDialog(
      title: Text(S.of(context).updatedQuran),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).ok),
        ),
      ],
    );
  }

  Widget _buildChooseDownloadMoshaf(BuildContext context) {
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
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(S.of(context).cancel),
        ),
        TextButton(
          autofocus: true,
          onPressed: () async {
            Navigator.pop(context);
            await ref.read(downloadQuranNotifierProvider.notifier).downloadQuran(selectedMoshafType);
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
        setState(() {
          selectedMoshafType = selected!;
        });
        ref.read(moshafTypeNotifierProvider.notifier).selectMoshafType(selectedMoshafType);
      },
    );
  }

  // Widget _buildLoadingDialog(BuildContext context) {
  //   return AlertDialog(
  //
  //     content: Center(child: CircularProgressIndicator()),
  //   );
  // }

  Widget _buildErrorDialog(BuildContext context, Object error) {
    if(error is CancelDownloadException) {
      return SizedBox();
    }
    return AlertDialog(
      title: Text(S.of(context).error),
      content: Text(error.toString()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).ok),
        ),
      ],
    );
  }
}
