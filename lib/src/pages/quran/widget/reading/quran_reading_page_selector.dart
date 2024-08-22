import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_notifer.dart';
import 'package:sizer/sizer.dart';

class QuranReadingPageSelector extends ConsumerStatefulWidget {
  final int totalPages;
  final int currentPage;
  final ScrollController scrollController;

  const QuranReadingPageSelector({
    required this.totalPages,
    required this.currentPage,
    required this.scrollController,
  });

  @override
  ConsumerState createState() => _QuranReadingPageSelectorState();
}

class _QuranReadingPageSelectorState extends ConsumerState<QuranReadingPageSelector> {
  // late FocusNode _initialFocusNode;

  @override
  void initState() {
    super.initState();
    // _initialFocusNode = FocusNode(debugLabel: 'node_page_${widget.currentPage}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _scrollToIndex(widget.currentPage);
      // FocusScope.of(context).requestFocus(_initialFocusNode);
    });
  }

  @override
  void dispose() {
    // _initialFocusNode.dispose();
    super.dispose();
  }

  // void _scrollToIndex(int index) {
  //   final itemHeight = 60.h / 4;
  //   final rowIndex = index ~/ 6;
  //   final offset = rowIndex * itemHeight;
  //   widget.scrollController.jumpTo(offset);
  // }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: SizedBox(
        width: double.maxFinite,
        child: Text(
          S.of(context).chooseQuranPage,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      content: Container(
        width: double.maxFinite,
        height: 60.h,
        child: GridView.builder(
          controller: widget.scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            childAspectRatio: 3 / 2,
          ),
          itemCount: widget.totalPages,
          itemBuilder: (BuildContext context, int index) {
            final isSelected = index == widget.currentPage;
            return InkWell(
              // focusNode: index == widget.currentPage ? _initialFocusNode : FocusNode(debugLabel: 'node_page_$index'),

              onTap: () {
                // _scrollToIndex(index);
                ref.read(quranReadingNotifierProvider.notifier).updatePage(index);
                Navigator.of(context).pop();
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).focusColor : null,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: isSelected ? FontWeight.bold : null,
                    color: isSelected ? Colors.white : null,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
