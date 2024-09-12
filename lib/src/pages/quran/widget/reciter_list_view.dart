import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';
import 'package:mawaqit/src/state_management/quran/recite/recite_notifier.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:sizer/sizer.dart';

class ReciterListView extends ConsumerStatefulWidget {
  final List<ReciterModel> reciters;
  final Function(int) onReciterSelected;
  final int selectedReciterIndex;

  // final List<FocusNode> reciterFocusNodes;

  const ReciterListView({
    super.key,
    required this.reciters,
    required this.onReciterSelected,
    required this.selectedReciterIndex,
    // required this.reciterFocusNodes,
  });

  @override
  createState() => _ReciterListViewState();
}

class _ReciterListViewState extends ConsumerState<ReciterListView> {
  final ScrollController _reciterScrollController = ScrollController();
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(
      widget.reciters.length,
      (index) => FocusNode(debugLabel: 'reciter_focus_node_$index'),
    );
  }

  @override
  void dispose() {
    _reciterScrollController.dispose();

    for (var element in _focusNodes) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('ui rebuild upon');
    return Container(
      height: 16.h,
      child: ListView.builder(
        controller: _reciterScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.reciters.length,
        itemBuilder: (context, index) {
          return InkWell(
            focusNode: _focusNodes[index],
            focusColor: Colors.transparent,
            onTap: () {
              print('reciter: reciter card $index tapped');
              widget.onReciterSelected(index);
              _focusNodes[index].requestFocus();
            },
            child: Builder(
              builder: (context) {
                print('reciter card $index rebuild ${Focus.of(context).toStringDeep()} ___ ${Focus.of(context).hasFocus} ___ ${index}');
                Focus.of(context).onKeyEvent = (node, event) {
                  if(event is KeyDownEvent){
                    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                      if (index < widget.reciters.length - 1) {
                        widget.onReciterSelected(index + 1);
                        Focus.of(context).nextFocus();
                      }
                      return KeyEventResult.handled;
                    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                      if (index > 0) {
                        widget.onReciterSelected(index - 1);
                        Focus.of(context).previousFocus();
                      }
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  }
                  return KeyEventResult.ignored;
                };
                return ReciterCard(
                  reciter: widget.reciters[index],
                  // isSelected: index == widget.selectedReciterIndex,
                  isSelected: Focus.of(context).hasFocus,
                  margin: EdgeInsets.only(right: 16),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ReciterCard extends ConsumerWidget {
  final ReciterModel reciter;
  final bool isSelected;
  final EdgeInsetsGeometry margin;

  const ReciterCard({
    super.key,
    required this.reciter,
    required this.isSelected,
    required this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReciterFavorite = ref.read(reciteNotifierProvider.notifier).isReciterFavorite(reciter);
    return Container(
      width: 25.w,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xFF490094),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            alignment: Alignment.bottomLeft,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                SizedBox(width: double.infinity),
                Expanded(
                  flex: 3,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double imageSize = constraints.maxWidth * 0.7;
                      return Image.asset(
                        R.ASSETS_IMG_QURAN_DEFAULT_AVATAR_PNG,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    reciter.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    minFontSize: 12,
                    maxFontSize: 20,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 4.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FavoriteReciterCard extends StatelessWidget {
  final ReciterModel reciter;
  final VoidCallback onRemove;

  const FavoriteReciterCard({
    Key? key,
    required this.reciter,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.w,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withOpacity(0.1),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(R.ASSETS_IMG_QURAN_DEFAULT_AVATAR_PNG),
              ),
              SizedBox(height: 8),
              Text(
                reciter.name,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 12.sp),
              ),
            ],
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: onRemove,
            ),
          ),
        ],
      ),
    );
  }
}
