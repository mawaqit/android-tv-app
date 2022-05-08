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
    var theme = Theme.of(context);

    theme = theme.copyWith(
      textTheme: isFocused ? theme.textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white) : null,
      cardColor: theme.brightness == Brightness.dark ? Colors.black45 : theme.primaryColor.withOpacity(.12),
    );

    return Theme(
      data: theme,
      child: Focus(
        onFocusChange: (i) => setState(() => isFocused = i),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100000)),
          color: isFocused ? Theme.of(context).focusColor : null,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            focusColor: isFocused ? Theme.of(context).focusColor : Colors.transparent,
            onTap: widget.onTap,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(backgroundImage: NetworkImage(widget.mosque.image ?? ''), radius: 32),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mosque.label ?? widget.mosque.name,
                      style: theme.textTheme.titleMedium,
                    ),
                    SizedBox(height: 2),
                    Text(
                      widget.mosque.localisation ?? '',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                )
              ],
            ),
            // child: ListTile(
            //   contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
            //   textColor: isFocused ? Colors.white : null,
            //   onTap: widget.onTap,
            //   leading: CircleAvatar(backgroundImage: NetworkImage(widget.mosque.image ?? '')),
            //   title: Text(widget.mosque.label ?? widget.mosque.name),
            //   subtitle: Text(widget.mosque.localisation ?? ''),
            // ),
          ),
        ),
      ),
    );
  }
}
