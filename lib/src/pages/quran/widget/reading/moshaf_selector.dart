import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_type_model.dart';

import 'package:mawaqit/src/helpers/connectivity_provider.dart';
import 'package:mawaqit/src/helpers/no_internet_toast.dart';
import 'package:mawaqit/src/state_management/quran/download_quran/download_quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/reading/moshaf_type_notifier.dart';
import 'package:sizer/sizer.dart';

import 'package:mawaqit/src/models/address_model.dart';

class MoshafSelector extends ConsumerWidget {
  final FocusNode focusNode;
  final bool isAutofocus;
  final bool isPortrait;

  const MoshafSelector({
    super.key,
    required this.focusNode,
    this.isPortrait = true,
    this.isAutofocus = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moshafTypeState = ref.watch(moshafTypeNotifierProvider);
    return moshafTypeState.maybeWhen(
      orElse: () => Container(),
      data: (state) {
        return state.selectedMoshaf.fold(
          () => Container(),
          (MoshafType selectedMoshaf) {
            final moshafName = switch (selectedMoshaf) {
              MoshafType.warsh => S.of(context).hafs,
              MoshafType.hafs => S.of(context).warsh,
              _ => throw Exception('Unexpected MoshafType: $selectedMoshaf'),
            };

            return Material(
              color: Colors.transparent,
              child: InkWell(
                autofocus: isAutofocus,
                focusNode: focusNode,
                onTap: () async {
                  final downloadNotifier = ref.read(downloadQuranNotifierProvider.notifier);
                  final isDownloaded = await downloadNotifier
                      .checkDownloaded(selectedMoshaf == MoshafType.hafs ? MoshafType.warsh : MoshafType.hafs);

                  if (isDownloaded) {
                    await downloadNotifier.switchMoshaf();
                  } else {
                    final shouldSwitch = await _showDownloadConfirmationDialog(context, moshafName, ref);
                    if (shouldSwitch) {
                      await downloadNotifier.switchMoshaf();
                    }
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: isPortrait ? 8 : 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      S.of(context).switchQuranType(moshafName),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _showDownloadConfirmationDialog(BuildContext context, String moshafName, WidgetRef ref) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(S.of(context).switchQuranType(moshafName)),
              actions: <Widget>[
                TextButton(
                  child: Text(S.of(context).cancel),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  autofocus: true,
                  child: Text(S.of(context).download),
                  onPressed: () async {
                    await ref.read(connectivityProvider.notifier).checkInternetConnection();
                    final connectivityStatus = ref.watch(connectivityProvider);
                    connectivityStatus.maybeWhen(
                      orElse: () {},
                      data: (connectivityStatus) {
                        if (connectivityStatus == ConnectivityStatus.connected) {
                          Navigator.of(context).pop(true);
                        } else {
                          NoInternetToast.show(S.of(context).noInternet);
                        }
                      },
                    );
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
