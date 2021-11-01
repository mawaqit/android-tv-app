import 'package:flutter/material.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:provider/provider.dart';

class SocialItem extends StatefulWidget {
  String icon_url;
  IconData icon;
  String text;
  Function onTap;

  SocialItem(
      {Key key,
      this.icon_url = "",
      this.icon = Icons.edit,
      this.text = "",
      this.onTap})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _SocialItem();
  }
}

class _SocialItem extends State<SocialItem> {
  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeNotifier>(context);
    return GestureDetector(
      child:
          _renderIcon(widget.icon_url, widget.icon, themeProvider.isLightTheme),
      onTap: widget.onTap,
    );
  }

  Widget _renderIcon(icon_url, icon, isLightTheme) {
    return Container(
        height: 22,
        width: 22,
        child: icon_url != ""
            ? Image.network(
                icon_url,
                width: 20,
                height: 20,
                //color: isLightTheme ? Colors.grey : Colors.white,
              )
            : Icon(icon));
  }
}
