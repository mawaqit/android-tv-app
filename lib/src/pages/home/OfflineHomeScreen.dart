import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/enum/home_active_screen.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_background_screen.dart';
import 'package:mawaqit/src/pages/home/workflow/jumua_workflow_screen.dart';
import 'package:mawaqit/src/pages/home/workflow/normal_workflow.dart';
import 'package:mawaqit/src/pages/home/workflow/salah_workflow.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

class OfflineHomeScreen extends StatelessWidget {
  OfflineHomeScreen({Key? key}) : super(key: key);

  Future<bool?> showClosingDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text(S.of(context).closeApp),
        content: new Text(S.of(context).sureCloseApp),
        actions: <Widget>[
          new TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text(S.of(context).cancel),
          ),
          SizedBox(height: 16),
          new TextButton(
            onPressed: () => exit(0),
            child: new Text(S.of(context).ok),
          ),
        ],
      ),
    );
  }

  Widget activeWorkflow(MosqueManager mosqueManager) {
    switch (mosqueManager.workflow) {
      case HomeActiveWorkflow.normal:
        return NormalWorkflowScreen();
      case HomeActiveWorkflow.salah:
        return SalahWorkflowScreen(onDone: mosqueManager.backToNormalHomeScreen);
      case HomeActiveWorkflow.jumuaa:
        return JumuaaWorkflowScreen(onDone: mosqueManager.backToNormalHomeScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.watch<MosqueManager>();

    return WillPopScope(
      onWillPop: () async => await showClosingDialog(context) ?? false,
      child: MosqueBackgroundScreen(child: activeWorkflow(mosqueProvider)),
    );
  }
}
