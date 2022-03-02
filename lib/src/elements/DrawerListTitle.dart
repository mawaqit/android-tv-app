import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/i18n.dart';
import 'package:mawaqit/src/services/theme_manager.dart';
import 'package:provider/provider.dart';

class DrawerListTitle extends StatefulWidget {
  String? iconUrl;
  IconData icon;
  String? text;
  void Function()? onTap;

  bool forceThemeColor;

  DrawerListTitle({
    Key? key,
    this.iconUrl,
    this.forceThemeColor = false,
    this.icon = Icons.edit,
    this.text = "",
    this.onTap,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _DrawerListTitle();
  }
}

class _DrawerListTitle extends State<DrawerListTitle> {
  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeNotifier>(context);
    return ListTile(
      title: Text(
        widget.text!,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 15.0),
      ),
      leading: _renderIcon(
        widget.iconUrl,
        widget.icon,
        themeProvider.getTheme()?.iconTheme.color,
      ),
      trailing: widget.onTap == null
          ? null
          : Icon(
              Directionality.of(context) == TextDirection.ltr
                  ? Icons.keyboard_arrow_right
                  : Icons.keyboard_arrow_left,
            ),
      onTap: widget.onTap,
    );
  }

  Widget _renderIcon(String? iconUrl, IconData icon, Color? color) {
    return iconUrl != null && iconUrl != ""
        ? Image.network(
            iconUrl,
            width: 20,
            height: 20,
            color: widget.forceThemeColor ? color : null,
          )
        : Icon(icon);
  }
}
