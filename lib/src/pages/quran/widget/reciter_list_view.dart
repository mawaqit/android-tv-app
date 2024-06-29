import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/src/state_management/quran/favorite/quran_favorite_notifier.dart';
import 'package:mawaqit/src/state_management/quran/recite/recite_notifier.dart';
import 'package:sizer/sizer.dart';

import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';

class ReciterListView extends ConsumerStatefulWidget {
  final List<ReciterModel> reciterList;
  final bool isFavoriteButton;
  final void Function(int) onSelected;

  const ReciterListView({
    super.key,
    required this.onSelected,
    required this.reciterList,
    required this.isFavoriteButton,
  });

  @override
  ConsumerState createState() => _ReciterListViewState();
}

class _ReciterListViewState extends ConsumerState<ReciterListView> {
  late final ScrollController _reciterScrollController;
  int selectedReciterIndex = 0;
  double marginOfContainerReciter = 16;

  @override
  void initState() {
    _reciterScrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _reciterScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16.h,
      child: ListView.builder(
        controller: _reciterScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.reciterList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              widget.onSelected(index);
              setState(() {
                selectedReciterIndex = index;
              });
            },
            child: _reciterCard(index, widget.reciterList),
          );
        },
      ),
    );
  }

  Container _reciterCard(int index, List<ReciterModel> reciterNames) {
    final isFavorite = ref.watch(quranFavoriteNotifierProvider).maybeWhen(
          data: (reciter) => reciter.favoriteReciters.map((e) => e.id).contains(reciterNames[index].id),
          orElse: () => false,
        );

    return Container(
      width: 25.w,
      margin: EdgeInsets.only(right: marginOfContainerReciter),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: selectedReciterIndex == index
            ? Border.all(
                color: Colors.white,
                width: 2,
              )
            : null,
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
                SizedBox(
                  width: double.infinity,
                ),
                Image.asset(
                  R.ASSETS_IMG_QURAN_DEFAULT_AVATAR_PNG,
                  width: 17.w,
                  fit: BoxFit.fitWidth,
                ),
                Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    reciterNames[index].name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 4,
            right: Directionality.of(context) == TextDirection.ltr ? 4 : null,
            left: Directionality.of(context) == TextDirection.rtl ? 4 : null,
            child: GestureDetector(
              onTap: () {
                if (isFavorite) {
                  ref.read(quranFavoriteNotifierProvider.notifier).deleteFavoriteReciter(
                        reciterId: reciterNames[index].id,
                      );
                } else {
                  ref.read(quranFavoriteNotifierProvider.notifier).saveFavoriteReciter(
                        reciterId: reciterNames[index].id,
                      );
                }
              },
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Theme.of(context).primaryColor : Colors.white,
                size: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}