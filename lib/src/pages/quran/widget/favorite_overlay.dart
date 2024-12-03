import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
import 'package:mawaqit/const/resource.dart';

class OverlayPage extends ConsumerStatefulWidget {
  final ReciterModel reciter;

  const OverlayPage({
    super.key,
    required this.reciter,
  });

  @override
  _OverlayPageState createState() => _OverlayPageState();
}

class _OverlayPageState extends ConsumerState<OverlayPage> with SingleTickerProviderStateMixin {
  late AnimationController _favoriteController;
  late Animation<double> _favoriteAnimation;

  @override
  void initState() {
    super.initState();
    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _favoriteAnimation = Tween<double>(begin: 1, end: 1.3).animate(
      CurvedAnimation(
        parent: _favoriteController,
        curve: Curves.elasticIn,
        reverseCurve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _favoriteController.dispose();
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
      body: BackgroundContainer(
        child: Row(
          children: [
            LeftPanel(
              reciter: widget.reciter,
              favoriteController: _favoriteController,
              favoriteAnimation: _favoriteAnimation,
            ),
            RightPanel(reciter: widget.reciter),
          ],
        ),
      ),
    );
  }
}

class BackgroundContainer extends StatelessWidget {
  final Widget child;

  const BackgroundContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(R.ASSETS_BACKGROUNDS_QURAN_BACKGROUND_PNG),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}

class LeftPanel extends StatelessWidget {
  final ReciterModel reciter;
  final AnimationController favoriteController;
  final Animation<double> favoriteAnimation;

  const LeftPanel({
    super.key,
    required this.reciter,
    required this.favoriteController,
    required this.favoriteAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.2,
        left: 30,
        right: 30,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Colors.black.withOpacity(0.0),
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReciterNameWidget(reciter: reciter),
          SizedBox(height: 20),
          FavoriteButton(
            reciter: reciter,
            favoriteController: favoriteController,
            favoriteAnimation: favoriteAnimation,
          ),
          SizedBox(height: 20),
          RecitationList(reciter: reciter),
        ],
      ),
    );
  }
}

class ReciterNameWidget extends StatelessWidget {
  final ReciterModel reciter;

  const ReciterNameWidget({super.key, required this.reciter});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        reciter.name,
        style: TextStyle(
          fontFamily: 'Bebas Neue',
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class FavoriteButton extends ConsumerWidget {
  final ReciterModel reciter;
  final AnimationController favoriteController;
  final Animation<double> favoriteAnimation;

  const FavoriteButton({
    super.key,
    required this.reciter,
    required this.favoriteController,
    required this.favoriteAnimation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReciterFavorite = ref.watch(reciteNotifierProvider).maybeWhen(
          data: (reciterState) => reciterState.favoriteReciters.contains(reciter),
          orElse: () => false,
        );

    return ElevatedButton.icon(
      style: ButtonStyle(
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
      ),
      onPressed: () => _handleFavoritePress(ref, isReciterFavorite),
      label: Text(S.of(context).favorites),
      icon: ScaleTransition(
        scale: favoriteAnimation,
        child: Icon(
          isReciterFavorite ? Icons.favorite : Icons.favorite_border,
          color: isReciterFavorite ? Colors.red : Colors.black,
        ),
      ),
    );
  }

  void _handleFavoritePress(WidgetRef ref, bool isReciterFavorite) {
    favoriteController.forward().then((_) => favoriteController.reverse());
    if (isReciterFavorite) {
      ref.read(reciteNotifierProvider.notifier).removeFavoriteReciter(reciter);
    } else {
      ref.read(reciteNotifierProvider.notifier).addFavoriteReciter(reciter);
    }
  }
}

class RecitationList extends StatelessWidget {
  final ReciterModel reciter;

  const RecitationList({super.key, required this.reciter});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: reciter.moshaf
              .map((e) => RecitationItem(
                    moshaf: e,
                    index: reciter.moshaf.indexOf(e),
                    reciter: reciter,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class RecitationItem extends ConsumerWidget {
  final MoshafModel moshaf;
  final int index;
  final ReciterModel reciter;

  const RecitationItem({
    super.key,
    required this.moshaf,
    required this.index,
    required this.reciter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: ElevatedButton(
        focusNode: FocusNode(),
        onPressed: () => _handlePress(context, ref),
        style: _buttonStyle(context),
        child: _buildButtonContent(moshaf),
      ),
    );
  }

  void _handlePress(BuildContext context, WidgetRef ref) {
    ref.read(reciteNotifierProvider.notifier).setSelectedMoshaf(
          moshafModel: moshaf,
        );

    ref.read(quranNotifierProvider.notifier).getSuwarByReciter(
          selectedMoshaf: moshaf,
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
            selectedMoshaf: moshaf,
          ),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    return ButtonStyle(
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
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      minimumSize: MaterialStateProperty.all<Size>(
        Size(double.infinity, 2.h),
      ),
    );
  }

  Widget _buildButtonContent(MoshafModel moshaf) {
    return Row(
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
    );
  }
}

class RightPanel extends StatelessWidget {
  final ReciterModel reciter;

  const RightPanel({super.key, required this.reciter});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: ReciterImage(reciter: reciter),
          ),
        ],
      ),
    );
  }
}

class ReciterImage extends StatelessWidget {
  final ReciterModel reciter;

  const ReciterImage({super.key, required this.reciter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: '${QuranConstant.kQuranReciterImagesBaseUrl}${reciter.id}.jpg',
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildLoadingWidget(),
          errorWidget: (context, url, error) => _buildErrorWidget(),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.black12,
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.black26,
      padding: EdgeInsets.all(20),
      child: Image.asset(
        R.ASSETS_SVG_RECITER_ICON_PNG,
        fit: BoxFit.contain,
      ),
    );
  }
}
