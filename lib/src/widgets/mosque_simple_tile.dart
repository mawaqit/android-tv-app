import 'package:flutter/material.dart';
import 'package:mawaqit/src/models/mosque.dart';

class MosqueSimpleTile extends StatelessWidget {
  const MosqueSimpleTile({Key? key, required this.mosque, this.onTap}) : super(key: key);

  final Mosque mosque;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(backgroundImage: NetworkImage(mosque.image ?? '')),
      title: Text(mosque.label ?? mosque.name),
      subtitle: Text(mosque.localisation ?? ''),
    );
  }
}
