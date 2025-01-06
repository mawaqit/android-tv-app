import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';
import 'package:mawaqit/src/pages/quran/page/surah_selection_screen.dart';
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
                            child: Text(
                              widget.reciter.name,
                              style: TextStyle(
                                fontFamily: 'Bebas Neue',
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Consumer(
                            builder: (context, ref, child) {
                              final isReciterFavorite = ref.watch(reciteNotifierProvider).maybeWhen(
                                    data: (reciterState) => reciterState.favoriteReciters.contains(widget.reciter),
                                    orElse: () => false,
                                  );
                              return ElevatedButton.icon(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      if (states.contains(MaterialState.focused)) {
                                        // Change color when button is focused
                                        return Colors.deepPurple.shade100;
                                      } else if (states.contains(MaterialState.hovered)) {
                                        // Optional change color when button is hovered over
                                        return Colors.red;
                                      } else {
                                        // Default color for other states (pressed, etc.)
                                        return Theme.of(context).colorScheme.primary;
                                      }
                                    },
                                  ),
                                ),
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
                                label: Text(S.of(context).favorites),
                                icon: Icon(
                                  isReciterFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isReciterFavorite ? Colors.red : Colors.black,
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 20),
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
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                '${QuranConstant.kQuranReciterImagesBaseUrl}${widget.reciter.id}.jpg',
                              ),
                              fit: BoxFit.contain, // Fit image to cover the area
                              alignment: Alignment.topRight,
                            ),
                          ),
                        ),
                        // Left Gradient Effect
                        Container(
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
                              stops: [0.2, 0.6],
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
    final focusNode = FocusNode();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: ElevatedButton(
        focusNode: focusNode,
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
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.focused)) {
                // Change color when button is focused
                return Colors.deepPurple.shade100;
              } else if (states.contains(MaterialState.hovered)) {
                // Optional change color when button is hovered over
                return Colors.red;
              } else {
                // Default color for other states (pressed, etc.)
                return Theme.of(context).colorScheme.primary;
              }
            },
          ),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          minimumSize: MaterialStateProperty.all<Size>(
            Size(double.infinity, 2.h),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.play_arrow, size: 24),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                moshaf.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
