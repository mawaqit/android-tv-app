import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/pages/home/widgets/AboveSalahBar.dart';
import 'package:mawaqit/src/widgets/display_text_widget.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/responsive_mini_salah_bar_widget.dart';
import 'package:provider/provider.dart';

import '../../../../i18n/AppLanguage.dart';
import '../../../const/constants.dart';
import '../../../helpers/StringUtils.dart';
import '../../../services/mosque_manager.dart';
import '../../../state_management/random_hadith/random_hadith_notifier.dart';
import '../widgets/salah_items/responsive_mini_salah_bar_turkish_widget.dart';

class RandomHadithScreen extends ConsumerStatefulWidget {
  const RandomHadithScreen({Key? key, this.onDone}) : super(key: key);

  final VoidCallback? onDone;

  @override
  ConsumerState<RandomHadithScreen> createState() => _RandomHadithScreenState();
}

class _RandomHadithScreenState extends ConsumerState<RandomHadithScreen> {
  String? hadith;

  @override
  void initState() {
    log('random_hadith: RandomHadithScreen initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hadith =
          context.read<AppLanguage>().hadithLanguage == '' ? 'ar' : context.read<AppLanguage>().hadithLanguage;
      ref.read(randomHadithNotifierProvider.notifier).getRandomHadith(language: hadith);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();
    final hadithState = ref.watch(randomHadithNotifierProvider);
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(R.ASSETS_BACKGROUNDS_BACKGROUND_ADHKAR_JPG),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
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
                return DisplayTextWidget.hadith(
                  translatedText: hadith.hadith,
                  textDirection: StringManager.getTextDirectionOfLocal(
                    Locale(mosqueManager.mosqueConfig!.hadithLang ?? 'en'),
                  ),
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) {
                widget.onDone?.call();
                return Center(
                  child: Text('Error: $error'),
                );
              },
            ),
          ),
          mosqueManager.times!.isTurki ? ResponsiveMiniSalahBarTurkishWidget() : ResponsiveMiniSalahBarWidget(),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
