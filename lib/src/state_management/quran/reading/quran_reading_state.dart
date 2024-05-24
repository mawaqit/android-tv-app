import 'package:equatable/equatable.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QuranReadingState extends Equatable {
  final int currentJuz;
  final int currentSurah;
  final int currentPage;
  final List<SvgPicture> svgs;
  final int totalPages;

  QuranReadingState({
    required this.currentJuz,
    required this.currentSurah,
    required this.currentPage,
    required this.svgs,
    required this.totalPages,
  });

  QuranReadingState copyWith({
    int? currentJuz,
    int? currentSurah,
    List<SvgPicture>? svgs,
    int? totalPages,
    int? currentPage,
  }) {
    return QuranReadingState(
      currentJuz: currentJuz ?? this.currentJuz,
      currentSurah: currentSurah ?? this.currentSurah,
      currentPage: currentPage ?? this.currentPage,
      svgs: svgs ?? this.svgs,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  List<Object> get props => [currentJuz, currentSurah, currentPage, svgs, totalPages];

  @override
  String toString() {
    return 'QuranReadingState{currentJuz: $currentJuz, currentSurah: $currentSurah, currentPage: $currentPage, svgs: ${svgs.length}, totalPages: $totalPages}';
  }
}
