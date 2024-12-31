import 'package:equatable/equatable.dart';

class ScreenLockState extends Equatable {
  final DateTime selectedTime;
  final bool isActive;
  final int selectedMinuteBefore;
  final int selectedMinuteAfter;
  final bool isfajrIshaonly;

  ScreenLockState({
    required this.selectedTime,
    required this.isActive,
    required this.selectedMinuteBefore,
    required this.selectedMinuteAfter,
    required this.isfajrIshaonly,
  });

  ScreenLockState copyWith({
    DateTime? selectedTime,
    bool? isActive,
    int? selectedMinuteBefore,
    int? selectedMinuteAfter,
    bool? isfajrIshaonly,
  }) {
    return ScreenLockState(
      selectedTime: selectedTime ?? this.selectedTime,
      isActive: isActive ?? this.isActive,
      selectedMinuteBefore: selectedMinuteBefore ?? this.selectedMinuteBefore,
      selectedMinuteAfter: selectedMinuteAfter ?? this.selectedMinuteAfter,
      isfajrIshaonly: isfajrIshaonly ?? this.isfajrIshaonly,
    );
  }

  List<Object> get props => [
        selectedTime,
        isActive,
        selectedMinuteBefore,
        selectedMinuteAfter,
        isfajrIshaonly,
      ];
}
