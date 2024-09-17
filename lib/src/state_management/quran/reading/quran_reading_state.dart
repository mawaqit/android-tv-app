import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QuranReadingState extends Equatable {
  final int currentJuz;
  final int currentSurah;
  final int currentPage;
  final List<SvgPicture> svgs;
  final PageController pageController;

  QuranReadingState({
    required this.currentJuz,
    required this.currentSurah,
    required this.currentPage,
    required this.svgs,
    required this.pageController,
  });

  QuranReadingState copyWith({
    int? currentJuz,
    int? currentSurah,
    List<SvgPicture>? svgs,
    int? currentPage,
    bool? isInitial,
    PageController? pageController,
  }) {
    return QuranReadingState(
      currentJuz: currentJuz ?? this.currentJuz,
      currentSurah: currentSurah ?? this.currentSurah,
      currentPage: currentPage ?? this.currentPage,
      svgs: svgs ?? this.svgs,
      pageController: pageController ?? this.pageController,
    );
  }

  @override
  List<Object> get props => [
        currentJuz,
        currentSurah,
        currentPage,
        svgs,
        pageController,
      ];

  int get totalPages => svgs.length;

  @override
  String toString() {
    return 'QuranReadingState{currentJuz: $currentJuz, currentSurah: $currentSurah, currentPage: $currentPage, '
        'svgs: ${svgs.length}, totalPages: $totalPages}';
  }
}
