import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sizer/sizer.dart';

class SurahCard extends ConsumerStatefulWidget {
  final String surahName;
  final int surahNumber;
  final int? verses;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback? onDownloadTap;
  final bool isFavorite;
  final bool isDownloaded;
  final double downloadProgress;

  const SurahCard({
    required this.surahName,
    required this.surahNumber,
    required this.isSelected,
    required this.onFavoriteTap,
    required this.onDownloadTap,
    required this.onTap,
    required this.downloadProgress,
    this.isFavorite = false,
    this.verses,
    this.isDownloaded = false,
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
    log('downloading log: ${widget.downloadProgress}');
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.isSelected ? Theme.of(context).primaryColor.withOpacity(0.8) : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: 10, top: 5, left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.downloadProgress > 0 && widget.downloadProgress < 1)
                    CircularPercentIndicator(
                      radius: 15.sp,
                      lineWidth: 3.sp,
                      percent: widget.downloadProgress,
                      progressColor: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      center: Text(
                        '${(widget.downloadProgress * 100).toInt()}%',
                        style: TextStyle(color: Colors.white, fontSize: 8.sp),
                      ),
                    )
                  else
                    IconButton(
                      onPressed: widget.onDownloadTap,
                      icon: Icon(
                        widget.isDownloaded ? Icons.download_done : Icons.download_rounded,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ),
                  IconButton(
                    onPressed: widget.onFavoriteTap,
                    icon: Icon(
                      widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                '${widget.surahNumber}. ${widget.surahName}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              widget.verses == null
                  ? Container()
                  : Text(
                      '${widget.verses} verses',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.white70,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
