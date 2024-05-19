import 'package:equatable/equatable.dart';
import 'package:mawaqit/src/domain/model/quran/language_model.dart';
import 'package:mawaqit/src/domain/model/quran/surah_model.dart';

enum QuranMode {
  reading,
  listening,
  none
}

class QuranState extends Equatable {
  final List<LanguageModel> languages;
  final List<SurahModel> suwar;
  final QuranMode mode;

  QuranState({
    this.mode = QuranMode.none,
    this.languages = const [],
    this.suwar = const [],
  });

  QuranState copyWith({
    List<LanguageModel>? languages,
    List<SurahModel>? suwar,
    QuranMode? mode,
  }) {
    return QuranState(
      languages: languages ?? this.languages,
      suwar: suwar ?? this.suwar,
      mode: mode ?? this.mode,
    );
  }

  @override
  String toString() {
    return 'QuranState{languages: ${languages[0]}, suwar: ${suwar[0]}}, mode: $mode}';
  }

  @override
  List<Object?> get props => [languages, suwar, mode];
}
