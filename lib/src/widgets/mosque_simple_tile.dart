import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/mawaqit_image/mawaqit_image_cache.dart';
import 'package:mawaqit/src/mawaqit_image/mawaqit_network_image.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/services/focus_manager.dart';

import 'package:mawaqit/src/helpers/CrashlyticsWrapper.dart';
import 'package:mawaqit/src/pages/home/OfflineHomeScreen.dart';
import 'package:sizer/sizer.dart';

class MosqueSimpleTile extends ConsumerStatefulWidget {
  const MosqueSimpleTile({
    Key? key,
    required this.mosque,
    this.onTap,
    this.selectedNode = const fp.None(),
    this.onFocusChange,
    this.focusNode,
    this.autoFocus,
    this.hasFocus = false,
  }) : super(key: key);

  final Mosque mosque;
  final Future<void> Function()? onTap;
  final void Function(bool i)? onFocusChange;
  final FocusNode? focusNode;
  final bool? autoFocus;
  final fp.Option<FocusNode> selectedNode;
  final bool hasFocus;

  @override
  ConsumerState<MosqueSimpleTile> createState() => _MosqueSimpleTileState();
}

class _MosqueSimpleTileState extends ConsumerState<MosqueSimpleTile> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    theme = theme.copyWith(
      textTheme: widget.hasFocus ? theme.textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white) : null,
      cardColor: theme.brightness == Brightness.dark ? Colors.black45 : theme.primaryColor.withOpacity(.12),
    );

    return Theme(
      data: theme,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100000)),
        color: widget.hasFocus ? Theme.of(context).focusColor : null,
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.symmetric(vertical: 2.h),
        child: InkWell(
          autofocus: widget.autoFocus ?? false,
          focusColor:
              widget.selectedNode.fold(() => null, (focus) => focus.hasFocus ? Theme.of(context).focusColor : null),
          onTap: () async {
            if (loading || widget.onTap == null || !mounted) return;
            try {
              setState(() => loading = true);
              await widget.onTap?.call();
              setState(() => loading = false);

              // Handle focus transfer after successful mosque selection
              widget.selectedNode.fold(
                () {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => OfflineHomeScreen()),
                    (route) => false,
                  );
                  return widget.onTap?.call();
                },
                (node) async {
                  // Add a small delay to ensure state updates are complete
                  await Future.delayed(Duration(milliseconds: 100));
                  if (mounted && node.canRequestFocus) {
                    // Use the FocusManager with proper error handling
                    await ref.read(focusManagerProvider).requestFocus(
                          node,
                          context: context,
                          timeout: const Duration(seconds: 2),
                        );
                  }
                },
              );
            } catch (e, s) {
              CrashlyticsWrapper.sendException(e, s);
              setState(() => loading = false);
              throw Exception('MosqueSimpleTile Error $e');
            }
          },
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: MawaqitNetworkImageProvider(
                    widget.mosque.image ?? '',
                  ),
                  radius: 16.sp,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mosque.label ?? widget.mosque.name,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    SizedBox(height: 2),
                    SizedBox(
                      width: 45.vw,
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        widget.mosque.localisation ?? '',
                        style: TextStyle(fontSize: 8.sp),
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
    );
  }
}
