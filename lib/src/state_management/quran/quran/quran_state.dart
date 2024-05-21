import 'package:equatable/equatable.dart';
import 'package:mawaqit/src/domain/model/quran/language_model.dart';
import 'package:mawaqit/src/domain/model/quran/surah_model.dart';

class QuranState extends Equatable {
  final List<LanguageModel> languages;
  final List<SurahModel> suwar;

  QuranState({
    this.languages = const [],
    this.suwar = const [],
  });

  QuranState copyWith({
    List<LanguageModel>? languages,
    List<SurahModel>? suwar,
  }) {
    return QuranState(
      languages: languages ?? this.languages,
      suwar: suwar ?? this.suwar,
    );
  }

  @override
  String toString() {
    return 'QuranState{languages: ${languages[0]}, suwar: ${suwar[0]}}';
  }

  @override
  List<Object?> get props => [languages, suwar];
}
