import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';
import 'package:mawaqit/src/pages/quran/widget/favorite_overlay.dart';
import 'package:mawaqit/src/state_management/quran/recite/recite_notifier.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:sizer/sizer.dart';

class ReciterListView extends ConsumerStatefulWidget {
  final List<ReciterModel> reciters;

  const ReciterListView({
    super.key,
    required this.reciters,
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
    return Container(
      height: widget.reciters.isNotEmpty ? 16.h : 0,
      child: ListView.builder(
        controller: _reciterScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.reciters.length,
        itemBuilder: (context, index) {
          return ReciterCard(
            reciter: widget.reciters[index],
            onTap: () {
              ref.read(reciteNotifierProvider.notifier).setSelectedReciter(
                reciterModel: widget.reciters[index],
              );
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => OverlayPage(
                    reciter: widget.reciters[index],
                  ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );
            },
            margin: EdgeInsets.only(right: 20),
          );
        },
      ),
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
        onTapCancel: _onTapCancel,

        onTap: widget.onTap,
        focusColor: Colors.transparent,
        child: Builder(
          builder: (context) {
            final hasFavorite = Focus.of(context).hasFocus ;
            return Container(
              width: 25.w,
              margin: widget.margin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: hasFavorite? Border.all(color: Colors.white, width: 2) : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FastCachedImage(
                      url: '${QuranConstant.kQuranReciterImagesBaseUrl}${widget.reciter.id}.jpg',
                      fit: BoxFit.cover,
                      loadingBuilder: (context, progress) => _buildOfflineImage(),
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
                        minFontSize: 10,
                        maxFontSize: 14,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
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
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Image.asset(
          R.ASSETS_SVG_RECITER_ICON_PNG,
          width: 24.w,
          height: 24.w,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
