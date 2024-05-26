import 'package:equatable/equatable.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QuranReadingState extends Equatable {
  final int currentJuz;
  final int currentSurah;
  final int currentPage;
  final List<SvgPicture> svgs;
  final int totalPages;
  final bool isInitial;

  QuranReadingState({
    required this.currentJuz,
    required this.currentSurah,
    required this.currentPage,
    required this.svgs,
    required this.isInitial,
    required this.totalPages,
  });

  QuranReadingState copyWith({
    int? currentJuz,
    int? currentSurah,
    List<SvgPicture>? svgs,
    int? totalPages,
    int? currentPage,
    bool? isInitial,
  }) {
    return QuranReadingState(
      currentJuz: currentJuz ?? this.currentJuz,
      currentSurah: currentSurah ?? this.currentSurah,
      currentPage: currentPage ?? this.currentPage,
      svgs: svgs ?? this.svgs,
      isInitial: isInitial ?? this.isInitial,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  List<Object> get props => [currentJuz, currentSurah, currentPage, svgs, totalPages, isInitial];

  @override
  String toString() {
    return 'QuranReadingState{currentJuz: $currentJuz, currentSurah: $currentSurah, currentPage: $currentPage, '
        'svgs: ${svgs.length}, totalPages: $totalPages, isInitial: $isInitial}';
  }
}
