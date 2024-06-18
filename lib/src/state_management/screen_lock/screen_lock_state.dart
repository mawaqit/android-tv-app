import 'package:equatable/equatable.dart';

class ScreenLockState extends Equatable {
  final DateTime selectedTime;
  final bool isActive;
  final int selectedMinuteBefore;
  final int selectedMinuteAfter;

  ScreenLockState({
    required this.selectedTime,
    required this.isActive,
    required this.selectedMinuteBefore,
    required this.selectedMinuteAfter,
  });

  ScreenLockState copyWith({
    DateTime? selectedTime,
    bool? isActive,
    int? selectedMinuteBefore,
    int? selectedMinuteAfter,
  }) {
    return ScreenLockState(
      selectedTime: selectedTime ?? this.selectedTime,
      isActive: isActive ?? this.isActive,
      selectedMinuteBefore: selectedMinuteBefore ?? this.selectedMinuteBefore,
      selectedMinuteAfter: selectedMinuteAfter ?? this.selectedMinuteAfter,
    );
  }

  List<Object> get props => [
        selectedTime,
        isActive,
        selectedMinuteBefore,
        selectedMinuteAfter,
      ];
}
