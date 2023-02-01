import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SocialItem extends StatelessWidget {
  final String? iconUrl;
  final IconData icon;
  final String? text;
  final void Function()? onTap;

  SocialItem({
    Key? key,
    this.iconUrl = "",
    this.icon = Icons.edit,
    this.text = "",
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(100),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        padding: EdgeInsets.all(5),
        icon: _renderIcon(iconUrl, icon),
        onPressed: onTap,
      ),
    );
  }

  Widget _renderIcon(String? iconUrl, IconData icon) {
    return Container(
      child: iconUrl != null && iconUrl != ""
          ? CachedNetworkImage(
              imageUrl: iconUrl,
              width: 20,
              height: 20,
            )
          : Icon(icon),
    );
  }
}
