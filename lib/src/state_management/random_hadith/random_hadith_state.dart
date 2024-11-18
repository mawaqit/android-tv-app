import 'package:equatable/equatable.dart';

class RandomHadithState extends Equatable {
  final String hadith;
  final String language;

  RandomHadithState({
    required this.hadith,
    required this.language,
  });

  RandomHadithState.initial() : hadith = '', language = '';

  RandomHadithState copyWith({
    String? hadith,
    String? language,
  }) {
    return RandomHadithState(
      hadith: hadith ?? this.hadith,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [hadith];
}
