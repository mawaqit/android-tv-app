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
  final bool isDownloaded;
  final double downloadProgress;
  final VoidCallback? onDownloadTap;

  const SurahCard({
    required this.surahName,
    required this.surahNumber,
    required this.isSelected,
    required this.onTap,
    this.isDownloaded = false,
    required this.downloadProgress,
    required this.onDownloadTap,
    this.verses,
  });

  @override
  ConsumerState<SurahCard> createState() => _SurahCardState();
}

class _SurahCardState extends ConsumerState<SurahCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isSelected ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                ],
              ),
              SizedBox(height: 5),
              Text(
                '${widget.surahNumber}. ${widget.surahName}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              widget.verses == null
                  ? Container()
                  : Text(
                      '$widget.verses verses',
                      style: TextStyle(
                        fontSize: 14,
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
