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

  const ReciterListView({
    super.key,
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
      child: Stack(
        children: [
          Positioned.fill(
            child: ListView.builder(
              controller: _reciterScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.reciterList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedReciterIndex = index;
                    });
                  },
                  child: _reciterCard(index, widget.reciterList),
                );
              },
            ),
          ),
          widget.isFavoriteButton
              ? Positioned(
                  right: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFavoriteButton(),
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return ref.watch(reciteNotifierProvider).maybeWhen(
      data: (recitersList) {
        final reciters = recitersList.reciters;
        final isFavorite = ref.watch(quranFavoriteNotifierProvider).maybeWhen(
          data: (reciter) =>
              reciter.favoriteReciters.map((e) => e.id).contains(reciters[selectedReciterIndex].id),
          orElse: () => false,
        );
        log('quran:ui: isFavorite: $isFavorite ${selectedReciterIndex}');
        return ElevatedButton(
          onPressed: () {
            log('quran:ui: isFavorite: $isFavorite ${selectedReciterIndex}');
            if (reciters.isEmpty) return;
            ref.read(quranFavoriteNotifierProvider.notifier).saveFavoriteReciter(
              reciterId: reciters[selectedReciterIndex].id,
            );
          },
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            backgroundColor: !isFavorite ? Colors.white.withOpacity(0.2) : Colors.red,
            fixedSize: Size(5.w, 5.w),
          ),
          child: Icon(
            !isFavorite ? Icons.favorite_border : Icons.favorite,
            color: Colors.white,
            size: 15.sp,
          ),
        );
      },
      orElse: () => Container(),
    );
  }

  Container _reciterCard(int index, List<ReciterModel> reciterNames) {
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
      child: Container(
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
                )),
          ],
        ),
      ),
    );
  }

}
