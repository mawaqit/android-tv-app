import 'package:flutter/material.dart';
import 'package:mawaqit/src/models/mosque.dart';

class MosqueSimpleTile extends StatefulWidget {
  const MosqueSimpleTile({Key? key, required this.mosque, this.onTap}) : super(key: key);

  final Mosque mosque;
  final void Function()? onTap;

  @override
  State<MosqueSimpleTile> createState() => _MosqueSimpleTileState();
}

class _MosqueSimpleTileState extends State<MosqueSimpleTile> {
  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (i) => setState(() => isFocused = i),
      child: ListTile(
        tileColor: isFocused ? Theme.of(context).focusColor : Colors.transparent,
        textColor: isFocused ? Colors.white : null,
        onTap: widget.onTap,
        leading: CircleAvatar(backgroundImage: NetworkImage(widget.mosque.image ?? '')),
        title: Text(widget.mosque.label ?? widget.mosque.name),
        subtitle: Text(widget.mosque.localisation ?? ''),
      ),
    );
  }
}
