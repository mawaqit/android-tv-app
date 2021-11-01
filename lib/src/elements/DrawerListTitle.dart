import 'package:flutter/material.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:provider/provider.dart';

class DrawerListTitle extends StatefulWidget {
  String icon_url;
  IconData icon;
  String text;
  Function onTap;

  DrawerListTitle(
      {Key key,
      this.icon_url = "",
      this.icon = Icons.edit,
      this.text = "",
      this.onTap})
      : super(key: key);

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
        widget.text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 15.0),
      ),
      leading:
          _renderIcon(widget.icon_url, widget.icon, themeProvider.isLightTheme),
      trailing: Icon(
        I18n.current.textDirection == TextDirection.ltr
            ? Icons.keyboard_arrow_right
            : Icons.keyboard_arrow_left,
      ),
      onTap: widget.onTap,
    );
  }

  Widget _renderIcon(icon_url, icon, isLightTheme) {
    return icon_url != ""
        ? Image.network(
            icon_url,
            width: 20,
            height: 20,
            //color: isLightTheme ? Colors.grey : Colors.white,
          )
        : Icon(
            icon,
          );
  }
}
