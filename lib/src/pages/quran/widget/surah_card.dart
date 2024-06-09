import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:sizer/sizer.dart';

class SurahCard extends ConsumerStatefulWidget {
  final String surahName;
  final int surahNumber;
  final int? verses;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final bool isFavorite;

  const SurahCard({
    required this.surahName,
    required this.surahNumber,
    required this.isSelected,
    required this.onFavoriteTap,
    required this.onTap,
    this.isFavorite = false,
    this.verses,
  });

  @override
  ConsumerState<SurahCard> createState() => _SurahCardState();
}


class _SurahCardState extends ConsumerState<SurahCard> {
  bool _isFocused = false;

  @override
  void initState() {
    _isFocused = widget.isFavorite;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.8)
              : _isFocused
              ? Theme.of(context).primaryColor.withOpacity(0.4)
              : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isFocused
              ? [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.4),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.surahNumber}. ${widget.surahName}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  widget.verses == null
                      ? Container()
                      : Text(
                    '${widget.verses} verses',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: isRTL ? null : 0,
              left: isRTL ? 0 : null,
              child: IconButton(
                onPressed: widget.onFavoriteTap,
                icon: Icon(
                  widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border,
                  color: Colors.redAccent,
                  size: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
