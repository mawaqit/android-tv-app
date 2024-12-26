import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';
import 'package:mawaqit/src/domain/model/quran/surah_model.dart';
import 'package:mawaqit/src/domain/model/schedule_model.dart';
import 'package:mawaqit/src/state_management/quran/schedule_listening/schedule_listening_notifier.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:sizer/sizer.dart';
import '../widget/schedule_screen_widgets/custom_scheduling_drop_down.dart';
import '../widget/schedule_screen_widgets/androidtv_timepicker.dart';
import '../widget/schedule_screen_widgets/focusable_timepicker.dart';
import '../widget/schedule_screen_widgets/custom_overlay_notification.dart';

class ScheduleScreen extends ConsumerWidget {
  ScheduleScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleState = ref.watch(scheduleNotifierProvider);
    final quranState = ref.watch(quranNotifierProvider);
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: scheduleState.when(
              data: (state) => _buildScheduleContent(state, context, ref),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleContent(
    ScheduleModel state,
    BuildContext context,
    WidgetRef ref,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 1.h),
        Text(
          S.of(context).scheduleListening,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),
        SwitchListTile(
          title: Text(
            S.of(context).enableScheduling,
            style: textTheme.titleMedium,
          ),
          value: state.isScheduleEnabled,
          onChanged: (bool value) {
            ref.read(scheduleNotifierProvider.notifier).setScheduleEnabled(value);
          },
        ),
        SizedBox(height: 2.h),
        Text(
          S.of(context).scheduleDesc,
          style: textTheme.bodyLarge,
        ),
        SizedBox(height: 2.h),
        if (state.isScheduleEnabled) ...[
          ..._buildScheduleOptions(state, context, ref),
          SizedBox(height: 2.h),
        ],
        _buildActionButtons(context, ref),
        SizedBox(height: 2.h),
      ],
    );
  }

  List<Widget> _buildScheduleOptions(
    ScheduleModel state,
    BuildContext context,
    WidgetRef ref,
  ) {
    return [
      _buildTimePicker(S.of(context).startTime, state.startTime, true, context, ref),
      const SizedBox(height: 16),
      _buildTimePicker(S.of(context).endTime, state.endTime, false, context, ref),
      const SizedBox(height: 24),
      _buildReciterDropdown(state, context, ref),
      const SizedBox(height: 16),
      if (state.selectedReciter != null) ...[
        _buildMoshafDropdown(state, context, ref),
        const SizedBox(height: 16),
      ],
      _buildRandomSurahCheckbox(state, context, ref),
      const SizedBox(height: 16),
      if (state.selectedMoshaf != null && !state.isRandomEnabled) _buildSurahDropdown(state, context, ref),
    ];
  }

  Widget _buildTimePicker(
    String label,
    TimeOfDay time,
    bool isStartTime,
    BuildContext context,
    WidgetRef ref,
  ) {
    return FocusableTimePicker(
      label: label,
      time: time,
      isStartTime: isStartTime,
      onTap: (BuildContext context, bool isStartTime) async {
        final scheduleNotifier = ref.read(scheduleNotifierProvider.notifier);
        final currentState = ref.read(scheduleNotifierProvider).value!;

        await showDialog(
          context: context,
          builder: (BuildContext context) => TVFriendlyTimePicker(
            initialTime: isStartTime ? currentState.startTime : currentState.endTime,
            onTimeSelected: (TimeOfDay selectedTime) async {
              if (isStartTime) {
                scheduleNotifier.setStartTime(selectedTime);
              } else {
                scheduleNotifier.setEndTime(selectedTime);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildReciterDropdown(ScheduleModel state, BuildContext context, WidgetRef ref) {
    return CustomDropdown<ReciterModel>(
      value: state.selectedReciter,
      items: state.reciterList,
      onChanged: (ReciterModel? newValue) {
        if (newValue != null) {
          ref.read(scheduleNotifierProvider.notifier).setSelectedReciter(newValue);
        }
      },
      hint: S.of(context).selectReciter,
      getLabel: (reciter) => reciter.name,
    );
  }

  Widget _buildMoshafDropdown(ScheduleModel state, BuildContext context, WidgetRef ref) {
    return CustomDropdown<MoshafModel>(
      value: state.selectedMoshaf,
      items: state.selectedReciter!.moshaf,
      onChanged: (MoshafModel? newValue) {
        if (newValue != null) {
          ref.read(scheduleNotifierProvider.notifier).setSelectedMoshaf(newValue);
        }
      },
      hint: S.of(context).selectMoshaf,
      getLabel: (moshaf) => moshaf.name,
    );
  }

  Widget _buildRandomSurahCheckbox(ScheduleModel state, BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return CheckboxListTile(
      activeColor: Theme.of(context).primaryColor,
      title: Text(
        S.of(context).randomSurahSelection,
        style: textTheme.titleMedium,
      ),
      value: state.isRandomEnabled,
      onChanged: (bool? value) {
        ref.read(scheduleNotifierProvider.notifier).setRandomEnabled(value ?? false);
      },
    );
  }

  Widget _buildSurahDropdown(
    ScheduleModel state,
    BuildContext context,
    WidgetRef ref,
  ) {
    final availableSurahs = state.selectedMoshaf!.surahList;
    final allSurahs = state.selectedSurahList;
    print('availableSurahs: $availableSurahs, allSurahs: $allSurahs');
    return allSurahs.isNotEmpty && state.selectedSurahId != null
        ? CustomDropdown<SurahModel>(
            value: allSurahs.firstWhere((surah) => surah.id == state.selectedSurahId),
            items: allSurahs.where((surah) => availableSurahs.contains(surah.id)).toList(),
            onChanged: (SurahModel? newValue) {
              if (newValue != null) {
                ref.read(scheduleNotifierProvider.notifier).setSelectedSurah(newValue.id);
              }
            },
            hint: S.of(context).selectSurah,
            getLabel: (surah) => surah.name,
          )
        : const SizedBox();
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            S.of(context).cancel,
            style: textTheme.bodyLarge,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.focused)) {
                  return Theme.of(context).primaryColor;
                }
                return null;
              },
            ),
          ),
          onPressed: () => _handleSaveSchedule(context, ref),
          child: Text(S.of(context).save),
        ),
      ],
    );
  }

  Future<void> _handleSaveSchedule(BuildContext context, WidgetRef ref) async {
    final scheduleNotifier = ref.read(scheduleNotifierProvider.notifier);
    scheduleNotifier.saveSchedule();
    _showNotification(context, S.of(context).scheduleSaved);
    Navigator.of(context).pop();
  }

  void _showNotification(BuildContext context, String message) {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => CustomOverlayNotification(
        message: message,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
