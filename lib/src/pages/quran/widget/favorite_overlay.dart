import 'package:cached_network_image/cached_network_image.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';
import 'package:mawaqit/src/pages/quran/page/surah_selection_screen.dart';
import 'package:mawaqit/src/routes/routes_constant.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/recite/recite_notifier.dart';
import 'package:sizer/sizer.dart';

class OverlayPage extends ConsumerStatefulWidget {
  final ReciterModel reciter;

  const OverlayPage({
    super.key,
    required this.reciter,
  });

  @override
  _OverlayPageState createState() => _OverlayPageState();
}

class _OverlayPageState extends ConsumerState<OverlayPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => {Navigator.pushReplacementNamed(context, Routes.quranReciter)},
        ),
      ),
      backgroundColor: Colors.black,
      body: KeyboardVisibilityBuilder(
        controller: KeyboardVisibilityController(),
        builder: (context, isKeyboardVisible) {
          if (isKeyboardVisible) {
            FocusScope.of(context).unfocus();
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  // Left column with text and buttons
                  SizedBox(
                    width: constraints.maxWidth * 0.4, // Limit width to 40% of screen
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.2,
                        left: 30,
                        right: 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.reciter.name,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Consumer(
                            builder: (context, ref, child) {
                              final isReciterFavorite = ref.watch(reciteNotifierProvider).maybeWhen(
                                    data: (reciterState) => reciterState.favoriteReciters.contains(widget.reciter),
                                    orElse: () => false,
                                  );
                              return SizedBox(
                                height: 5.h,
                                child: ElevatedButton.icon(
                                  autofocus: true,
                                  style: commonButtonStyle,
                                  onPressed: () {
                                    if (isReciterFavorite) {
                                      ref.read(reciteNotifierProvider.notifier).removeFavoriteReciter(
                                            widget.reciter,
                                          );
                                    } else {
                                      ref.read(reciteNotifierProvider.notifier).addFavoriteReciter(
                                            widget.reciter,
                                          );
                                    }
                                  },
                                  icon: Icon(
                                    isReciterFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: isReciterFavorite ? Colors.red : Colors.black,
                                    size: 3.h, // Make icon size consistent
                                  ),
                                  label: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      S.of(context).favorites,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 3.h),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: widget.reciter.moshaf
                                    .map((e) => _buildElevatedOption(e, widget.reciter.moshaf.indexOf(e)))
                                    .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Right side for the image and gradient effects
                  Expanded(
                    child: Stack(
                      children: [
                        // Background Image
                        Builder(
                          builder: (context) {
                            final isRTL = Directionality.of(context) == TextDirection.rtl;
                            return Align(
                              alignment: isRTL ? Alignment.centerLeft : Alignment.centerRight,
                              child: Container(
                                height: constraints.maxHeight,
                                child: FastCachedImage(
                                  url: '${QuranConstant.kQuranReciterImagesBaseUrl}${widget.reciter.id}.jpg',
                                  fit: BoxFit.fitHeight,
                                  alignment: Alignment.topRight,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildOfflineImage();
                                  },
                                  loadingBuilder: (context, progress) {
                                    return Container(
                                      color: Colors.black,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value: progress.progressPercentage.value,
                                        ),
                                      ),
                                    );
                                  },
                                  fadeInDuration: const Duration(milliseconds: 500),
                                ),
                              ),
                            );
                          },
                        ),
                        // Left Gradient Effect
                        Container(
                          width: 60.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: AlignmentDirectional.centerStart,
                              end: AlignmentDirectional.centerEnd,
                              colors: [
                                Colors.black,
                                Colors.transparent,
                              ],
                              stops: [0.2, 1.0],
                            ),
                          ),
                        ),
                        // Bottom Gradient Effect
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black,
                                Colors.transparent,
                              ],
                              stops: [0.1, 0.9],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildElevatedOption(MoshafModel moshaf, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: SizedBox(
        height: 5.h,
        child: ElevatedButton(
          onPressed: () {
            ref.read(reciteNotifierProvider.notifier).setSelectedMoshaf(
                  moshafModel: widget.reciter.moshaf[index],
                );

            ref.read(quranNotifierProvider.notifier).getSuwarByReciter(
                  selectedMoshaf: widget.reciter.moshaf[index],
                );

            final Option<ReciterModel> selectedReciterId = ref.watch(reciteNotifierProvider).maybeWhen(
                  orElse: () => none(),
                  data: (reciterState) => reciterState.selectedReciter,
                );

            selectedReciterId.fold(
              () => null,
              (reciter) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SurahSelectionScreen(
                    reciterId: reciter.id.toString(),
                    selectedMoshaf: widget.reciter.moshaf[index],
                  ),
                ),
              ),
            );
          },
          style: commonButtonStyle,
          child: Row(
            children: [
              Icon(Icons.play_arrow, size: 3.h),
              SizedBox(width: 2.w),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    moshaf.name,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle get commonButtonStyle => ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
        ),
        fixedSize: MaterialStateProperty.all<Size>(
          Size(60.w, 8.h), // Same size for both buttons
        ),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.focused)) {
              return Colors.deepPurple.shade100;
            } else if (states.contains(MaterialState.hovered)) {
              return Colors.red;
            }
            return Theme.of(context).colorScheme.primary;
          },
        ),
      );

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
