import 'package:flutter/material.dart';

import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';
import 'package:mawaqit/src/domain/model/quran/surah_model.dart';

class ScheduleModel {
  final bool isScheduleEnabled;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ReciterModel? selectedReciter;
  final MoshafModel? selectedMoshaf;
  final int? selectedSurahId;
  final List<SurahModel> selectedSurahList;
  final bool isRandomEnabled;
  final List<ReciterModel> reciterList;

  ScheduleModel({
    required this.isScheduleEnabled,
    required this.startTime,
    required this.endTime,
    required this.isRandomEnabled,
    required this.reciterList,
    this.selectedReciter,
    this.selectedMoshaf,
    this.selectedSurahId,
    this.selectedSurahList = const [],
  });

  ScheduleModel copyWith({
    bool? isScheduleEnabled,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    ReciterModel? selectedReciter,
    MoshafModel? selectedMoshaf,
    int? selectedSurahId,
    bool? isRandomEnabled,
    List<ReciterModel>? reciterList,
    List<SurahModel>? selectedSurahList,
  }) {
    return ScheduleModel(
      isScheduleEnabled: isScheduleEnabled ?? this.isScheduleEnabled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      selectedReciter: selectedReciter ?? this.selectedReciter,
      selectedMoshaf: selectedMoshaf ?? this.selectedMoshaf,
      selectedSurahId: (isRandomEnabled ?? this.isRandomEnabled) ? null : (selectedSurahId ?? this.selectedSurahId),
      isRandomEnabled: isRandomEnabled ?? this.isRandomEnabled,
      reciterList: reciterList ?? this.reciterList,
      selectedSurahList: selectedSurahList ?? this.selectedSurahList,
    );
  }

}
