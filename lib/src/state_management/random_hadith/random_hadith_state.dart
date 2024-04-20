import 'package:equatable/equatable.dart';

class RandomHadithState extends Equatable {
  final String hadith;

  RandomHadithState({
    required this.hadith,
  });

  RandomHadithState.initial() : hadith = '';

  RandomHadithState copyWith({
    String? hadith,
  }) {
    return RandomHadithState(
      hadith: hadith ?? this.hadith,
    );
  }

  @override
  List<Object?> get props => [hadith];
}
