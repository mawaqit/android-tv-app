import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/mawaqit_image/mawaqit_network_image.dart';

class DrawerListTitle extends StatefulWidget {
  final String? iconUrl;
  final IconData icon;
  final String? text;
  final void Function()? onTap;

  final bool forceThemeColor;
  final bool autoFocus;

  /// translate the title or not
  final bool autoTranslate;

  DrawerListTitle({
    Key? key,
    this.iconUrl,
    this.forceThemeColor = false,
    this.icon = Icons.edit,
    this.text = "",
    this.onTap,
    this.autoFocus = false,
    this.autoTranslate = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _DrawerListTitle();
}

class _DrawerListTitle extends State<DrawerListTitle> {
  late bool isFocused = widget.autoFocus;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (i) => setState(() => isFocused = i),
      child: ListTile(
        autofocus: widget.autoFocus,
        tileColor:
            isFocused ? Theme.of(context).focusColor : Colors.transparent,
        textColor: isFocused
            ? Colors.white
            : Theme.of(context).textTheme.bodyMedium?.color,
        title: Text(
          widget.autoTranslate
              ? Intl.message(widget.text ?? '', name: widget.text?.toCamelCase)
              : widget.text ?? '',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 15.0),
        ),
        leading: _renderIcon(
          widget.iconUrl,
          widget.icon,
          isFocused
              ? Colors.white
              : Theme.of(context).textTheme.bodyMedium?.color,
        ),
        trailing: widget.onTap == null
            ? null
            : Icon(
                Directionality.of(context) == TextDirection.ltr
                    ? Icons.keyboard_arrow_right
                    : Icons.keyboard_arrow_left,
                color: isFocused
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
        onTap: widget.onTap,
      ),
    );
  }

  Widget _renderIcon(String? iconUrl, IconData icon, Color? color) {
    return iconUrl != null && iconUrl != ""
        ? MawaqitNetworkImage(
            imageUrl: iconUrl,
            width: 20,
            height: 20,
            color: widget.forceThemeColor ? color : null,
          )
        : Icon(icon, color: color);
  }
}
