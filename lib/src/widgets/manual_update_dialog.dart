import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/state_management/app_update/app_update_notifier.dart';
import 'package:mawaqit/src/state_management/manual_app_update/manual_update_notifier.dart';
import 'package:mawaqit/src/state_management/on_boarding/on_boarding.dart';

import '../state_management/manual_app_update/manual_update_state.dart';

class UpdateDialogMessages {
  static Map<UpdateStatus, String> getLocalizedMessage(BuildContext context) {
    return {
      UpdateStatus.checking: S.of(context).checkingForUpdates,
/*       UpdateStatus.available: S.of(context).updateAvailable,
 */
      UpdateStatus.notAvailable: S.of(context).usingLatestVersion,
      UpdateStatus.downloading: S.of(context).downloadingUpdate,
      UpdateStatus.installing: S.of(context).installingUpdate,
      UpdateStatus.completed: S.of(context).updateCompleted,
      UpdateStatus.cancelled: S.of(context).updateCancelled,
      UpdateStatus.error: S.of(context).updateFailed,
    };
  }
}

class UpdateDialog {
  static void show(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final updateState = ref.watch(manualUpdateNotifierProvider);
          return AlertDialog(
            title: Text(S.of(context).updateAvailable),
            content: _buildDialogContent(context, updateState),
            actions: _buildDialogActions(context, ref),
          );
        },
      ),
    );
  }

  static Widget _buildDialogContent(BuildContext context, AsyncValue<UpdateState> updateState) {
    final localizedMessages = UpdateDialogMessages.getLocalizedMessage(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (updateState.value?.currentVersion != null && updateState.value?.availableVersion != null) ...[
          Text(S.of(context).appUpdateAvailable(
              updateState.value?.currentVersion as String, updateState.value?.availableVersion as String)),
          const SizedBox(height: 8),
        ],
        if (updateState.value?.status == UpdateStatus.error)
          Text(
            updateState.value?.message ?? S.of(context).updateFailed,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          )
        else
          Text(
            localizedMessages[updateState.value?.status] ?? S.of(context).wouldYouLikeToUpdate,
          ),
        if (updateState.value?.progress != null) ...[
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: updateState.value?.progress,
            backgroundColor: Theme.of(context).colorScheme.background,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(updateState.value!.progress! * 100).toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }

  static List<Widget> _buildDialogActions(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(manualUpdateNotifierProvider);
    final isUpdating =
        updateState.value?.status == UpdateStatus.downloading || updateState.value?.status == UpdateStatus.installing;

    return [
      TextButton(
        onPressed: () {
          ref.read(manualUpdateNotifierProvider.notifier).cancelUpdate();
          Navigator.pop(context);
        },
        child: Text(S.of(context).cancel),
      ),
      TextButton(
        onPressed: isUpdating ? null : () => _handleUpdateAction(context, ref),
        child: Text(S.of(context).update),
      ),
    ];
  }

  static void _handleUpdateAction(BuildContext context, WidgetRef ref) {
    final isDeviceRooted = ref.read(onBoardingProvider).maybeWhen(
          orElse: () => false,
          data: (value) => value.isRootedDevice,
        );

    if (isDeviceRooted) {
      ref.read(manualUpdateNotifierProvider.notifier).downloadAndInstallUpdate();
    } else {
      ref.read(appUpdateProvider.notifier).openStore();
      Navigator.pop(context);
    }
  }

  static void showNoUpdateAvailableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).noUpdates),
        content: Text(S.of(context).usingLatestVersion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).ok),
          ),
        ],
      ),
    );
  }
}
