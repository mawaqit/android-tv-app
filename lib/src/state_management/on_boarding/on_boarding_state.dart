import 'package:equatable/equatable.dart';

class OnBoardingState extends Equatable {
  final int currentScreen;
  final bool isCompleted;

  OnBoardingState({this.currentScreen = 0, this.isCompleted = false});

  OnBoardingState copyWith({int? currentScreen, bool? isCompleted}) {
    return OnBoardingState(
      currentScreen: currentScreen ?? this.currentScreen,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [currentScreen, isCompleted];
}
