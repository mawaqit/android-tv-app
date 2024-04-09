import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/models/address_model.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

import '../../../helpers/connectivity_provider.dart';
import '../../../services/user_preferences_manager.dart';
import '../../../widgets/mawaqit_youtube_palyer.dart';
import 'JumuaHadithSubScreen.dart';

class JummuaLive extends ConsumerStatefulWidget {
  const JummuaLive({
    Key? key,
    this.onDone,
  }) : super(key: key);

  final VoidCallback? onDone;

  @override
  ConsumerState createState() => _JummuaLiveState();
}

class _JummuaLiveState extends ConsumerState<JummuaLive> {
  /// invalid channel id
  bool invalidStreamUrl = false;

  @override
  void initState() {
    invalidStreamUrl = context.read<MosqueManager>().mosque?.streamUrl == null;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.read<MosqueManager>();
    final userPrefs = context.watch<UserPreferencesManager>();
    final connectivity = ref.watch(connectivityProvider);

    /// disable live stream in mosque primary screen
    final jumuaaDisableInMosque = !userPrefs.isSecondaryScreen && mosqueManager.typeIsMosque;

    return switch (connectivity) {
      AsyncData(:final value) =>
        switchStreamWidget(value, mosqueManager, jumuaaDisableInMosque),
      _ => CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), // Green color
      ),
    };
  }

  Widget switchStreamWidget(ConnectivityStatus connectivityStatus,
      MosqueManager mosqueManager, bool jumuaaDisableInMosque) {
    if (invalidStreamUrl ||
        mosqueManager.mosque?.streamUrl == null ||
        jumuaaDisableInMosque ||
        connectivityStatus == ConnectivityStatus.disconnected) {
      if (mosqueManager.mosqueConfig!.jumuaDhikrReminderEnabled == true) return JumuaHadithSubScreen(onDone: widget.onDone);

      return Scaffold(backgroundColor: Colors.black);
    } else {
      return MawaqitYoutubePlayer(
        channelId: mosqueManager.mosque!.streamUrl!,
        onDone: widget.onDone,
        muted: mosqueManager.typeIsMosque,
        onNotFound: () => setState(() => invalidStreamUrl = true),
      );
    }
  }
}
