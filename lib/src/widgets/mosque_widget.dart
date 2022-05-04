import 'package:flutter/material.dart';
import 'package:mawaqit/src/models/mosque.dart';

class MosqueTileWidget extends StatelessWidget {
  const MosqueTileWidget({Key? key, required this.mosque, this.onTap}) : super(key: key);
  final Mosque mosque;

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: Colors.deepPurple[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(mosque.image)),
          title: Text(mosque.name),
          subtitle: Text(mosque.location ?? ''),
        ),
      ),
    );
  }
}
