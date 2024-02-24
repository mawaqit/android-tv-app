import 'package:equatable/equatable.dart';

class RandomHadithState extends Equatable {
  final String hadith;

  RandomHadithState({
    required this.hadith,
  });

  RandomHadithState.initial() : hadith = '';

  @override
  List<Object?> get props => [hadith];
}
