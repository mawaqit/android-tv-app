import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:sizer/sizer.dart';

class SurahCard extends ConsumerStatefulWidget {
  final String surahName;
  final int surahNumber;
  final int? verses;
  final VoidCallback onTap;
  final bool isDownloaded;
  final double downloadProgress;
  final VoidCallback? onDownloadTap;
  final int index;

  const SurahCard({
    required this.surahName,
    required this.surahNumber,
    required this.onTap,
    required this.index,
    this.isDownloaded = false,
    required this.downloadProgress,
    required this.onDownloadTap,
    this.verses,
  });

  @override
  ConsumerState<SurahCard> createState() => _SurahCardState();
}

class _SurahCardState extends ConsumerState<SurahCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      autofocus: widget.index == 0,
      onTap: widget.onTap,
      onHover: (isHovering) {
        if (isHovering) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      },
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Builder(
              builder: (context) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color:
                            Focus.of(context).hasFocus ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${widget.surahNumber}. ${widget.surahName}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white,

                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (widget.verses != null) SizedBox(height: 8),
                            if (widget.verses != null)
                              Text(
                                '${widget.verses} verses',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.white70,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: _buildDownloadTag(),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDownloadTag() {
    if (widget.isDownloaded) {
      return Container();
    } else if (widget.downloadProgress > 0 && widget.downloadProgress < 1) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(14),
          ),
        ),
        child: Text(
          '${(widget.downloadProgress * 100).toInt()}%',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: widget.onDownloadTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 2.sp),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
          ),
          child: Text(
            S.of(context).download,
            style: TextStyle(
              color: Colors.white,
              fontSize: 8.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }
}
