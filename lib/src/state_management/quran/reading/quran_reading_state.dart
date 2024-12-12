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
  final String currentSurahName;
  final bool isRotated;

  QuranReadingState({
    required this.currentJuz,
    required this.currentSurah,
    required this.currentPage,
    required this.svgs,
    required this.pageController,
    required this.suwar,
    required this.currentSurahName,
    this.isRotated = false,
  });

  QuranReadingState copyWith({
    int? currentJuz,
    int? currentSurah,
    List<SvgPicture>? svgs,
    int? currentPage,
    bool? isInitial,
    PageController? pageController,
    List<SurahModel>? suwar,
    String? currentSurahName,
    bool? isRotated,
  }) {
    return QuranReadingState(
      currentJuz: currentJuz ?? this.currentJuz,
      currentSurah: currentSurah ?? this.currentSurah,
      currentPage: currentPage ?? this.currentPage,
      svgs: svgs ?? this.svgs,
      pageController: pageController ?? this.pageController,
      suwar: suwar ?? this.suwar,
      currentSurahName: currentSurahName ?? this.currentSurahName,
      isRotated: isRotated ?? this.isRotated,
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
        currentSurahName,
        isRotated,
      ];

  int get totalPages => svgs.length;

  @override
  String toString() {
    return 'QuranReadingState{currentJuz: $currentJuz, currentSurah: $currentSurah, currentPage: $currentPage, '
        'svgs: ${svgs.length}, totalPages: $totalPages, pageController: $pageController, suwar: ${suwar.length}, '
        'isRotated: $isRotated}';
  }
}
