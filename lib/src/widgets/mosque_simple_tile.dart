import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/mawaqit_image/mawaqit_image_cache.dart';
import 'package:mawaqit/src/models/mosque.dart';

import 'package:mawaqit/src/helpers/CrashlyticsWrapper.dart';
import 'package:mawaqit/src/pages/home/OfflineHomeScreen.dart';

class MosqueSimpleTile extends StatefulWidget {
  const MosqueSimpleTile({
    Key? key,
    required this.mosque,
    this.onTap,
    this.selectedNode = const fp.None(),
    this.onFocusChange,
    this.focusNode,
    this.autoFocus,
  }) : super(key: key);

  final Mosque mosque;
  final Future<void> Function()? onTap;
  final void Function(bool i)? onFocusChange;
  final FocusNode? focusNode;
  final bool? autoFocus;
  final fp.Option<FocusNode> selectedNode;

  @override
  State<MosqueSimpleTile> createState() => _MosqueSimpleTileState();
}

class _MosqueSimpleTileState extends State<MosqueSimpleTile> {
  bool isFocused = false;

  bool loading = false;

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
        focusNode: widget.focusNode,
        onFocusChange: (i) {
          widget.onFocusChange?.call(i);
          setState(() => isFocused = i);
        },
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100000)),
          color: isFocused ? Theme.of(context).focusColor : null,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            autofocus: widget.autoFocus ?? false,
            focusColor: isFocused ? Theme.of(context).focusColor : Colors.transparent,
            onTap: () async {
              if (loading || widget.onTap == null || !mounted) return;
              try {
                setState(() => loading = true);
                await widget.onTap?.call();
                setState(() => loading = false);
              } catch (e, s) {
                CrashlyticsWrapper.sendException(e, s);
                setState(() => loading = false);
                throw Exception('MosqueSimpleTile Error $e');
              }

              widget.selectedNode.fold(() {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => OfflineHomeScreen()),
                  (route) => false,
                );
                return widget.onTap?.call();
              }, (node) {
                Future.delayed(Duration(milliseconds: 200), () {
                  node.requestFocus();
                });
                return ;
              });
            },
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundImage: MawaqitNetworkImageProvider(
                      widget.mosque.image ?? '',
                    ),
                    radius: 32,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.mosque.label ?? widget.mosque.name,
                        style: theme.textTheme.titleMedium,
                      ),
                      SizedBox(height: 2),
                      SizedBox(
                        width: 45.vw,
                        child: Text(
                          overflow: TextOverflow.ellipsis,
                          widget.mosque.localisation ?? '',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                if (loading) Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
