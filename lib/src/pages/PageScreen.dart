import 'package:flutter/material.dart' hide Page;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mawaqit/src/helpers/HexColor.dart';
import 'package:mawaqit/src/models/page.dart';
import 'package:mawaqit/src/models/settings.dart';
import 'package:mawaqit/src/widgets/MawaqitWebViewWidget.dart';
import 'package:mawaqit/src/services/settings_manager.dart';
import 'package:provider/provider.dart';

/// displays data on dynamic pages of drawer
class PageScreen extends StatefulWidget {
  final Page page;

  const PageScreen(this.page);

  @override
  State<StatefulWidget> createState() => new _PageScreen();
}

class _PageScreen extends State<PageScreen> {
  InAppWebViewController? _webViewController;

  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    final settingsManager = Provider.of<SettingsManager>(context);
    final settings = settingsManager.settings;

    return Scaffold(
      appBar: _renderAppBar(context, settings, widget.page),
      body: MawaqitWebViewWidget(
        path: widget.page.url,
      ),
    );
  }
}

AppBar _renderAppBar(context, Settings settings, Page page) {
  return AppBar(
      title: Text(
        page.title!,
        style: TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[
              Theme.of(context).brightness == Brightness.light
                  ? HexColor(settings.firstColor)
                  : Theme.of(context).primaryColor,
              Theme.of(context).brightness == Brightness.light
                  ? HexColor(settings.secondColor)
                  : Theme.of(context).primaryColor,
            ],
          ),
        ),
      ));
}

const extractContent = '''
  const header = document.querySelector(".header");
  header?.parentElement.removeChild(header);

  const footer = document.querySelector(".footer");
  footer?.parentElement.removeChild(footer);

  const breadcrumb = document.querySelector(".breadcrumb");
  breadcrumb?.parentElement.removeChild(breadcrumb);
''';
