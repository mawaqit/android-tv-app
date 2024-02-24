import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/helpers/PerformanceHelper.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/pages/home/widgets/AboveSalahBar.dart';
import 'package:mawaqit/src/pages/home/widgets/HadithScreen.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/responsive_mini_salah_bar_widget.dart';
import 'package:provider/provider.dart';

import '../../../helpers/StringUtils.dart';
import '../../../services/mosque_manager.dart';

class RandomHadithScreen extends StatefulWidget {
  const RandomHadithScreen({Key? key, this.onDone}) : super(key: key);

  final VoidCallback? onDone;

  @override
  State<RandomHadithScreen> createState() => _RandomHadithScreenState();
}

class _RandomHadithScreenState extends State<RandomHadithScreen> {
  String? hadith;

  @override
  void initState() {
    final mosqueManager = context.read<MosqueManager>();
    mosqueManager
        .getRandomHadith()
        .then(
          (value) => setState(() => hadith = value),
        )
        .catchError(
          (e) => widget.onDone?.call(),
        );
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      ref.read(randomHadithNotifierProvider.notifier).getRandomHadith(
            language: mosqueManager.mosqueConfig!.hadithLang ?? 'ar',
          );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();
    final hadithState = ref.watch(randomHadithNotifierProvider);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: AboveSalahBar(),
        ),
        Expanded(
          // child: HadithWidget(
          //   translatedText: context.watch<MosqueManager>().hadith,
          //   textDirection: StringManager.getTextDirectionOfLocal(
          //     Locale(mosqueManager.mosqueConfig!.hadithLang ?? 'en'),
          //   ),
          // ),
          child: hadithState.when(
            data: (hadith) {
              return HadithWidget(
                translatedText: hadith.hadith,
                textDirection: StringManager.getTextDirectionOfLocal(
                  Locale(mosqueManager.mosqueConfig!.hadithLang ?? 'en'),
                ),
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => Center(
              child: Text('Error: $error'),
            ),
          ),
        ),
        ResponsiveMiniSalahBarWidget(),
        SizedBox(height: 4.vh),
      ],
    );
  }
}
