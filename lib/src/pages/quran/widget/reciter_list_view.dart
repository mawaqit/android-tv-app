import 'package:device_info_plus/device_info_plus.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';
import 'package:mawaqit/src/helpers/TimeShiftManager.dart';
import 'package:mawaqit/src/pages/quran/widget/optimized_image_load.dart';
import 'package:mawaqit/src/state_management/quran/recite/recite_notifier.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:sizer/sizer.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ReciterListView extends ConsumerStatefulWidget {
  final List<ReciterModel> reciters;

  const ReciterListView({
    super.key,
    required this.reciters,
  });

  @override
  createState() => _ReciterListViewState();
}

class _ReciterListViewState extends ConsumerState<ReciterListView> {
  final ScrollController _reciterScrollController = ScrollController();
  late List<FocusNode> _focusNodes;
  late String _deviceModel;
  @override
  void initState() {
    super.initState();
    _initializeFocusNodes();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _deviceModel = await _getDeviceModel();
    });
  }

  Future<String> _getDeviceModel() async {
    var hardware = await DeviceInfoPlugin().androidInfo;
    return hardware.model;
  }

  void _initializeFocusNodes() {
    _focusNodes = List.generate(
      widget.reciters.length,
      (index) => FocusNode(debugLabel: 'reciter_focus_node_$index'),
    );
    for (var node in _focusNodes) {
      node.addListener(() => _handleFocusChange(node));
    }
  }

  @override
  void didUpdateWidget(ReciterListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reciters.length != oldWidget.reciters.length) {
      _disposeFocusNodes();
      _initializeFocusNodes();
    }
  }

  void _disposeFocusNodes() {
    for (var node in _focusNodes) {
      node.removeListener(() => _handleFocusChange(node));
      node.dispose();
    }
  }

  void _handleFocusChange(FocusNode node) {
    if (node.hasFocus) {
      final index = _focusNodes.indexOf(node);
      if (index >= 0 && index < widget.reciters.length) {
        ref.read(reciteNotifierProvider.notifier).setSelectedReciter(
              reciterModel: widget.reciters[index],
            );
      }
    }
  }

  @override
  void dispose() {
    _reciterScrollController.dispose();
    _disposeFocusNodes();
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
          if (index >= _focusNodes.length) {
            return SizedBox(); // Return an empty widget if the index is out of bounds
          }
          return InkWell(
            focusNode: _focusNodes[index],
            focusColor: Colors.transparent,
            onTap: () {
              ref.read(reciteNotifierProvider.notifier).setSelectedReciter(
                    reciterModel: widget.reciters[index],
                  );
              _focusNodes[index].requestFocus();
            },
            child: Builder(
              builder: (context) {
                return ReciterCard(
                  deviceModel: _deviceModel,
                  reciter: widget.reciters[index],
                  isSelected: Focus.of(context).hasFocus,
                  margin: EdgeInsets.only(right: 20),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ReciterCard extends ConsumerWidget {
  final ReciterModel reciter;
  final bool isSelected;
  final EdgeInsetsGeometry margin;
  final String deviceModel;

  const ReciterCard({
    super.key,
    required this.reciter,
    required this.isSelected,
    required this.margin,
    required this.deviceModel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 25.w,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            RegExp(r'ONVO.*').hasMatch(deviceModel)
                ? OptimizedCachedImage(
                    reciterId: reciter.id.toString(),
                    fit: BoxFit.fitWidth,
                    baseUrl: QuranConstant.kQuranReciterImagesBaseUrl,
                    offlineImageBuilder: _buildOfflineImage,
                  )
                : FastCachedImage(
                    url: '${QuranConstant.kQuranReciterImagesBaseUrl}${reciter.id}.jpg',
                    fit: BoxFit.fitWidth,
                    loadingBuilder: (context, progress) => Container(color: Colors.transparent),
                    errorBuilder: (context, error, stackTrace) => _buildOfflineImage()),
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
                reciter.name,
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
  }

  // Helper method to build a smaller offline image
  Widget _buildOfflineImage() {
    return Center(
      child: Container(
        width: 24.w,
        height: 24.w,
        padding: EdgeInsets.only(bottom: 2.h),
        child: Image.asset(
          "assets/svg/reciter_icon-compressed.png",
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
