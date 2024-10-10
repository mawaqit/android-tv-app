import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mawaqit/src/domain/model/quran/surah_model.dart';

class QuranReadingState extends Equatable {
  final int currentJuz;
  final int currentSurah;
  final int currentPage;
  final List<SvgPicture> svgs;
  final PageController pageController;
  final List<SurahModel> suwar;

  QuranReadingState({
    required this.currentJuz,
    required this.currentSurah,
    required this.currentPage,
    required this.svgs,
    required this.pageController,
    required this.suwar,
  });

  QuranReadingState copyWith({
    int? currentJuz,
    int? currentSurah,
    List<SvgPicture>? svgs,
    int? currentPage,
    bool? isInitial,
    PageController? pageController,
    List<SurahModel>? suwar,
  }) {
    return QuranReadingState(
      currentJuz: currentJuz ?? this.currentJuz,
      currentSurah: currentSurah ?? this.currentSurah,
      currentPage: currentPage ?? this.currentPage,
      svgs: svgs ?? this.svgs,
      pageController: pageController ?? this.pageController,
      suwar: suwar ?? this.suwar,
    );
  }

  @override
  List<Object> get props => [
        currentJuz,
        currentSurah,
        currentPage,
        svgs,
        pageController,
        suwar,
      ];

  int get totalPages => svgs.length;

  @override
  String toString() {
    return 'QuranReadingState{currentJuz: $currentJuz, currentSurah: $currentSurah, currentPage: $currentPage, '
        'svgs: ${svgs.length}, totalPages: $totalPages}';
  }
}
