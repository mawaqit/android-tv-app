import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/models/address_model.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

import '../../../helpers/connectivity_provider.dart';
import 'mosque_background_screen.dart';

class OfflineWidget extends ConsumerStatefulWidget {
  const OfflineWidget({super.key});

  @override
  ConsumerState createState() => _OfflineWidgetState();
}

class _OfflineWidgetState extends ConsumerState<OfflineWidget> {
  @override
  Widget build(BuildContext context) {
    final tr = S.of(context);
    final connectivity = ref.watch(connectivityProvider);
    return switch (connectivity) {
      AsyncData(:final value) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
                print('open drawer');
              },
            ),
            CircleAvatar(
              radius: .4.vwr,
              backgroundColor: value == ConnectivityStatus.connected ? Colors.green : Colors.red[700],
            ),
            SizedBox(width: .4.vwr),
            Text(
              value == ConnectivityStatus.connected ? tr.online : tr.offline,
              style: TextStyle(
                color: Colors.white,
                shadows: kHomeTextShadow,
                fontSize: 1.vwr,
                height: 1.1,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      AsyncError(:final error) => Container(),
      _ => const CircularProgressIndicator(),
    };
  }
}
