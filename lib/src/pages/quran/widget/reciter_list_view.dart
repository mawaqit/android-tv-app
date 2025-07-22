import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';
import 'package:mawaqit/src/pages/quran/page/reciter_selection_screen.dart';
import 'package:mawaqit/src/routes/route_generator.dart';
import 'package:mawaqit/src/routes/routes_constant.dart';
import 'package:mawaqit/src/state_management/quran/recite/recite_notifier.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:sizer/sizer.dart';
import 'package:mawaqit/src/const/constants.dart';

class ReciterListView extends ConsumerStatefulWidget {
  final List<ReciterModel> reciters;
  final bool isAtBottom;

  const ReciterListView({
    super.key,
    required this.reciters,
    required this.isAtBottom,
  });

  @override
  _ReciterListViewState createState() => _ReciterListViewState();
}

class _ReciterListViewState extends ConsumerState<ReciterListView> {
  final ScrollController _reciterScrollController = ScrollController();

  @override
  void dispose() {
    _reciterScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final isRTL = Directionality.of(context) == TextDirection.rtl;
        final buttonsPadding = 18.w; // Padding for floating action buttons

        return Padding(
          padding: EdgeInsets.only(
            right: isRTL ? ReciterSelectionScreen.horizontalPadding : 0,
            left: isRTL ? 0 : ReciterSelectionScreen.horizontalPadding,
          ),
          child: Container(
            // Only apply padding if this is the bottom list
            padding: widget.isAtBottom
                ? EdgeInsets.only(right: isRTL ? 0 : buttonsPadding, left: isRTL ? buttonsPadding : 0)
                : null,
            child: ListView.builder(
              controller: _reciterScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.reciters.length,
              itemBuilder: (context, index) {
                return ReciterCard(
                  key: ValueKey(widget.reciters[index].id),
                  reciter: widget.reciters[index],
                  onTap: () {
                    ref.read(reciteNotifierProvider.notifier).setSelectedReciter(
                          reciterModel: widget.reciters[index],
                        );

                    Navigator.of(context).pushReplacement(
                      RouteGenerator.buildReciterFavoriteRoute(
                        RouteSettings(
                          name: Routes.quranReciterFavorite,
                          arguments: {
                            'reciter': widget.reciters[index],
                          },
                        ),
                      ),
                    );
                  },
                  margin: EdgeInsets.only(right: 2.w),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class ReciterCard extends ConsumerStatefulWidget {
  final ReciterModel reciter;
  final VoidCallback onTap;
  final EdgeInsetsGeometry margin;

  const ReciterCard({
    super.key,
    required this.reciter,
    required this.onTap,
    required this.margin,
  });

  @override
  _ReciterCardState createState() => _ReciterCardState();
}

class _ReciterCardState extends ConsumerState<ReciterCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: InkWell(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        autofocus: FocusScope.of(context).hasFocus,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        focusColor: Colors.transparent,
        child: Builder(
          builder: (context) {
            final hasFavorite = Focus.of(context).hasFocus;
            return Container(
              width: 25.w,
              margin: widget.margin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: hasFavorite ? Border.all(color: Colors.white, width: 2) : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FastCachedImage(
                      url: '${QuranConstant.kQuranReciterImagesBaseUrl}${widget.reciter.id}.jpg',
                      fit: BoxFit.fitWidth,
                      cacheWidth: QuranConstant.kCacheWidth,
                      cacheHeight: QuranConstant.kCacheHeight,
                      loadingBuilder: (context, progress) => Container(color: Colors.transparent),
                      errorBuilder: (context, error, stackTrace) => _buildOfflineImage(),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(1),
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.3, 0.4],
                        ),
                      ),
                    ),
                    // Name at the bottom
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 8,
                      child: AutoSizeText(
                        widget.reciter.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 8.sp,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOfflineImage() {
    return Center(
      child: Container(
        padding: EdgeInsets.only(bottom: 2.h),
        child: Image.asset(
          R.ASSETS_SVG_RECITER_ICON_PNG,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
