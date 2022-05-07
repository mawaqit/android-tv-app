import 'package:flutter/material.dart';

class DrawerListTitle extends StatefulWidget {
  final String? iconUrl;
  final IconData icon;
  final String? text;
  final void Function()? onTap;

  final bool forceThemeColor;

  DrawerListTitle({
    Key? key,
    this.iconUrl,
    this.forceThemeColor = false,
    this.icon = Icons.edit,
    this.text = "",
    this.onTap,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _DrawerListTitle();
}

class _DrawerListTitle extends State<DrawerListTitle> {
  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (i) => setState(() => isFocused = i),
      child: ListTile(
        tileColor: isFocused ? Theme.of(context).focusColor : Colors.transparent,
        textColor: isFocused ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
        title: Text(
          widget.text!,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15.0,
          ),
        ),
        leading: _renderIcon(
          widget.iconUrl,
          widget.icon,
          isFocused ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
        ),
        trailing: widget.onTap == null
            ? null
            : Icon(
                Directionality.of(context) == TextDirection.ltr
                    ? Icons.keyboard_arrow_right
                    : Icons.keyboard_arrow_left,
              ),
        onTap: widget.onTap,
      ),
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
        : Icon(icon, color: color);
  }
}
