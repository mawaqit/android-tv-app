import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../domain/model/quran/moshaf_model.dart';
import '../../../domain/model/quran/reciter_model.dart';

class ScheduleState extends Equatable {
  final bool isScheduleEnabled;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ReciterModel? selectedReciter;
  final MoshafModel? selectedMoshaf;
  final int? selectedSurahId;
  final bool isRandomEnabled;
  final List<ReciterModel> reciterList;

  const ScheduleState({
    this.isScheduleEnabled = false,
    required this.startTime,
    required this.endTime,
    this.selectedReciter,
    this.selectedMoshaf,
    this.selectedSurahId,
    this.isRandomEnabled = false,
    this.reciterList = const [],
  });

  factory ScheduleState.initial() => ScheduleState(
        startTime: TimeOfDay(hour: 8, minute: 0),
        endTime: TimeOfDay(hour: 20, minute: 0),
      );

  ScheduleState copyWith({
    bool? isScheduleEnabled,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    ReciterModel? selectedReciter,
    MoshafModel? selectedMoshaf,
    int? selectedSurahId,
    bool? isRandomEnabled,
    List<ReciterModel>? reciterList,
  }) {
    return ScheduleState(
      isScheduleEnabled: isScheduleEnabled ?? this.isScheduleEnabled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      selectedReciter: selectedReciter ?? this.selectedReciter,
      selectedMoshaf: selectedMoshaf ?? this.selectedMoshaf,
      // If random is enabled, clear the surah selection
      selectedSurahId: (isRandomEnabled ?? this.isRandomEnabled) ? null : (selectedSurahId ?? this.selectedSurahId),
      isRandomEnabled: isRandomEnabled ?? this.isRandomEnabled,
      reciterList: reciterList ?? this.reciterList,
    );
  }

  @override
  List<Object?> get props => [
        isScheduleEnabled,
        startTime.hour,
        startTime.minute,
        endTime.hour,
        endTime.minute,
        selectedReciter?.id,
        selectedMoshaf?.id,
        selectedSurahId,
        isRandomEnabled,
        reciterList.map((r) => r.id).toList(),
      ];
}
