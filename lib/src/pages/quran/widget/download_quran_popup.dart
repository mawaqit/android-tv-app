import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';

import 'package:mawaqit/src/domain/error/quran_exceptions.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_type_model.dart';
import 'package:mawaqit/src/routes/routes_constant.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_state.dart';
import 'package:mawaqit/src/state_management/quran/reading/moshaf_type_notifier.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_notifer.dart';

class DownloadQuranDialog extends ConsumerStatefulWidget {
  const DownloadQuranDialog({super.key});

  @override
  _DownloadQuranDialogState createState() => _DownloadQuranDialogState();
}

class _DownloadQuranDialogState extends ConsumerState<DownloadQuranDialog> {
  MoshafType selectedMoshafType = MoshafType.hafs;
  late FocusNode _dialogFocusNode;

  @override
  void initState() {
    super.initState();
    _dialogFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdate();
    });
  }

  @override
  void dispose() {
    _dialogFocusNode.dispose();
    super.dispose();
  }

  void _checkForUpdate() {
    final notifier = ref.read(downloadQuranNotifierProvider.notifier);
    // notifier.checkForUpdate(notifier.selectedMoshafType);
  }

  @override
  Widget build(BuildContext context) {
    final downloadState = ref.watch(downloadQuranNotifierProvider);

    return downloadState.when(
      data: (data) => _buildDialogContent(context, data),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorDialog(context, error),
    );
  }

  Widget _buildDialogContent(BuildContext context, DownloadQuranState state) {
    return switch (state) {
      NeededDownloadedQuran() => _buildChooseDownloadMoshaf(context),
      Downloading() => _buildDownloadingDialog(context, state),
      Extracting() => _buildExtractingDialog(context, state),
      Success() => _handleSuccess(context),
      CancelDownload() => const SizedBox(),
      UpdateAvailable() => _buildUpdateAvailableDialog(context, state),
      _ => const SizedBox(),
    };
  }

  Widget _handleSuccess(BuildContext context) {
    // Auto close dialog on success
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop();
    });
    return const SizedBox();
  }

  Widget _buildContent(BuildContext context, DownloadQuranState state) {
    // return Container();
    return switch (state) {
      NeededDownloadedQuran() => _buildChooseDownloadMoshaf(context),
      // UpdateAvailable() => _buildUpdateAvailableDialog(context, state),
      Downloading() => _buildDownloadingDialog(context, state),
      Extracting() => _buildExtractingDialog(context, state),
      Success() => _successDialog(context),
      CancelDownload() => Container(),
      // NoUpdate() => _buildNoUpdateDialog(context, state),
      _ => Container(),
      // DownloadQuranState() => null,
    };
  }

  Widget _buildUpdateAvailableDialog(BuildContext context, UpdateAvailable state) {
    final moshafName = switch (state.moshafType) {
      MoshafType.warsh => S.of(context).warsh,
      MoshafType.hafs => S.of(context).hafs,
    };

    return AlertDialog(
      title: Text(S.of(context).updateAvailable),
      content: Text(S.of(context).quranUpdateDialogContent(moshafName, state.version)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).cancel),
        ),
        TextButton(
          autofocus: true,
          onPressed: () {
            final notifier = ref.read(downloadQuranNotifierProvider.notifier);
            notifier.downloadQuran(state.moshafType);
          },
          child: Text(S.of(context).download),
        ),
      ],
    );
  }

  Widget _buildDownloadingDialog(BuildContext context, Downloading state) {
    return Focus(
      focusNode: _dialogFocusNode,
      child: AlertDialog(
        title: Text(S.of(context).downloadingQuran),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: state.progress / 100,
              color: Colors.white,
              backgroundColor: Colors.black,
            ),
            SizedBox(height: 16),
            Text('${state.progress.toStringAsFixed(2)}%'),
          ],
        ),
        actions: [
          TextButton(
            autofocus: true,
            onPressed: () async {
              final notifier = ref.read(downloadQuranNotifierProvider.notifier);
              final moshafType = ref.watch(moshafTypeNotifierProvider);
              ref.read(moshafTypeNotifierProvider).maybeWhen(
                    orElse: () {},
                    data: (state) async {
                      state.selectedMoshaf.fold(() {
                        return null;
                      }, (selectedMoshaf) async {
                        await notifier.cancelDownload(selectedMoshaf); // Await cancellation
                      });
                    },
                  );
              moshafType.when(
                data: (data) {
                  if (data.isFirstTime) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  } else {
                    Navigator.pop(context);
                  }
                },
                error: (_, __) {},
                loading: () {},
              );
            },
            child: Text(S.of(context).cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractingDialog(BuildContext context, Extracting state) {
    return Focus(
      focusNode: _dialogFocusNode,
      child: AlertDialog(
        title: Text(S.of(context).extractingQuran),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: state.progress / 100,
              color: Colors.white,
              backgroundColor: Colors.black,
            ),
            SizedBox(height: 16),
            Text('${state.progress.toStringAsFixed(2)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildNoUpdateDialog(BuildContext context, NoUpdate state) {
    return AlertDialog(title: Text(S.of(context).updatedQuran), actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(S.of(context).ok),
      ),
    ]);
  }

  Widget _buildChooseDownloadMoshaf(BuildContext context) {
    return Focus(
      focusNode: _dialogFocusNode,
      child: AlertDialog(
        title: Text(S.of(context).chooseQuranType),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMoshafTypeRadio(
              context,
              title: S.of(context).warsh,
              value: MoshafType.warsh,
              setState: setState,
              autofocus: selectedMoshafType == MoshafType.warsh,
            ),
            _buildMoshafTypeRadio(
              context,
              title: S.of(context).hafs,
              value: MoshafType.hafs,
              setState: setState,
              autofocus: selectedMoshafType == MoshafType.hafs,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final moshafType = ref.watch(moshafTypeNotifierProvider);
              moshafType.when(
                data: (data) {
                  if (data.isFirstTime) {
                    Navigator.pushNamedAndRemoveUntil(context, Routes.quranModeSelection, (route) => route.isFirst);
                  } else {
                    Navigator.pop(context);
                  }
                },
                error: (_, __) {},
                loading: () {},
              );
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
      ),
    );
  }

  Widget _buildMoshafTypeRadio(
    BuildContext context, {
    required String title,
    required MoshafType value,
    required void Function(VoidCallback fn) setState,
    bool autofocus = false,
  }) {
    return RadioListTile<MoshafType>(
      title: Text(title),
      value: value,
      autofocus: autofocus,
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
    if (error is CancelDownloadException) {
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

  Widget _successDialog(BuildContext context) {
    return Container();
  }
}
