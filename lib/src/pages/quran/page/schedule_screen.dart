import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/pages/quran/widget/schedule_screen_widgets/custom_scheduling_drop_down.dart';
import 'package:mawaqit/src/state_management/quran/schedule_listening/schedule_listening_notifier.dart';
import 'package:sizer/sizer.dart';
import '../../../domain/model/quran/moshaf_model.dart';
import '../../../domain/model/quran/reciter_model.dart';
import '../widget/schedule_screen_widgets/androidtv_timepicker.dart';
import '../widget/schedule_screen_widgets/focusable_timepicker.dart';
import '../widget/schedule_screen_widgets/custom_overlay_notification.dart';
import '../../../state_management/quran/quran/quran_notifier.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  final List<ReciterModel> reciterList;

  const ScheduleScreen({
    super.key,
    required this.reciterList,
  });

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quranNotifierProvider.notifier).getSuwarByLanguage();
      ref.read(scheduleProvider.notifier).updateReciterList(widget.reciterList);
    });
  }

  Future<void> _handleSaveSchedule() async {
    final success = await ref.read(scheduleProvider.notifier).saveSchedule();
    if (success) {
      _showNotification(S.of(context).scheduleSaved);
      if (mounted) Navigator.of(context).pop();
    } else {
      _showNotification(S.of(context).completeAllFields);
    }
  }

  void _showNotification(String message) {
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

  Future<void> _handleTimeSelection(BuildContext context, bool isStartTime) async {
    final scheduleNotifier = ref.read(scheduleProvider.notifier);
    final currentState = ref.read(scheduleProvider).value!;

    await showDialog(
      context: context,
      builder: (BuildContext context) => TVFriendlyTimePicker(
        initialTime: isStartTime ? currentState.startTime : currentState.endTime,
        onTimeSelected: (TimeOfDay selectedTime) async {
          if (isStartTime) {
            await _handleStartTimeSelection(selectedTime, currentState, scheduleNotifier);
          } else {
            await _handleEndTimeSelection(selectedTime, scheduleNotifier);
          }
        },
      ),
    );
  }

  Future<void> _handleStartTimeSelection(
    TimeOfDay selectedTime,
    dynamic currentState,
    dynamic scheduleNotifier,
  ) async {
    await scheduleNotifier.setStartTime(selectedTime);
    final endTime = currentState.endTime;

    if (_shouldAdjustEndTime(selectedTime, endTime)) {
      await scheduleNotifier.setEndTime(
        TimeOfDay(
          hour: (selectedTime.hour + 1) % 24,
          minute: selectedTime.minute,
        ),
      );
    }
  }

  bool _shouldAdjustEndTime(TimeOfDay selectedTime, TimeOfDay endTime) {
    return endTime.hour < selectedTime.hour ||
        (endTime.hour == selectedTime.hour && endTime.minute <= selectedTime.minute);
  }

  Future<void> _handleEndTimeSelection(
    TimeOfDay selectedTime,
    dynamic scheduleNotifier,
  ) async {
    final success = await scheduleNotifier.setEndTime(selectedTime);
    if (!success) {
      _showNotification(S.of(context).endTimeAfter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<dynamic> scheduleState = ref.watch(scheduleProvider);
    final AsyncValue<dynamic> quranState = ref.watch(quranNotifierProvider);

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
              data: (state) => _buildScheduleContent(state, quranState, context),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleContent(
    dynamic state,
    AsyncValue<dynamic> quranState,
    BuildContext context,
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
            ref.read(scheduleProvider.notifier).setScheduleEnabled(value);
          },
        ),
        SizedBox(height: 2.h),
        Text(
          S.of(context).scheduleDesc,
          style: textTheme.bodyLarge,
        ),
        SizedBox(height: 2.h),
        if (state.isScheduleEnabled) ...[
          ..._buildScheduleOptions(state, quranState),
          SizedBox(height: 2.h),
        ],
        _buildActionButtons(context),
        SizedBox(height: 2.h),
      ],
    );
  }

  List<Widget> _buildScheduleOptions(dynamic state, AsyncValue<dynamic> quranState) {
    return [
      _buildTimePicker(S.of(context).startTime, state.startTime, true),
      const SizedBox(height: 16),
      _buildTimePicker(S.of(context).endTime, state.endTime, false),
      const SizedBox(height: 24),
      _buildReciterDropdown(state),
      const SizedBox(height: 16),
      if (state.selectedReciter != null) ...[
        _buildMoshafDropdown(state),
        const SizedBox(height: 16),
      ],
      _buildRandomSurahCheckbox(state, context),
      const SizedBox(height: 16),
      if (state.selectedMoshaf != null && !state.isRandomEnabled) _buildSurahDropdown(state, quranState),
    ];
  }

  Widget _buildTimePicker(String label, TimeOfDay time, bool isStartTime) {
    return FocusableTimePicker(
      label: label,
      time: time,
      isStartTime: isStartTime,
      onTap: _handleTimeSelection,
    );
  }

  Widget _buildReciterDropdown(dynamic state) {
    return CustomDropdown<ReciterModel>(
      value: state.selectedReciter,
      items: widget.reciterList,
      onChanged: (ReciterModel? newValue) {
        ref.read(scheduleProvider.notifier).setSelectedReciter(newValue);
      },
      hint: S.of(context).selectReciter,
      getLabel: (reciter) => reciter.name,
    );
  }

  Widget _buildMoshafDropdown(dynamic state) {
    return CustomDropdown<MoshafModel>(
      value: state.selectedMoshaf,
      items: state.selectedReciter!.moshaf,
      onChanged: (MoshafModel? newValue) {
        ref.read(scheduleProvider.notifier).setSelectedMoshaf(newValue);
      },
      hint: S.of(context).selectMoshaf,
      getLabel: (moshaf) => moshaf.name,
    );
  }

  Widget _buildRandomSurahCheckbox(dynamic state, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return CheckboxListTile(
      activeColor: Theme.of(context).primaryColor,
      title: Text(
        S.of(context).randomSurahSelection,
        style: textTheme.titleMedium,
      ),
      value: state.isRandomEnabled,
      onChanged: (bool? value) {
        ref.read(scheduleProvider.notifier).setRandomEnabled(value ?? false);
      },
    );
  }

  Widget _buildSurahDropdown(dynamic state, AsyncValue<dynamic> quranState) {
    return quranState.when(
      data: (data) => CustomDropdown<int>(
        value: state.selectedSurahId,
        items: state.selectedMoshaf!.surahList,
        onChanged: (int? newValue) {
          ref.read(scheduleProvider.notifier).setSelectedSurahId(newValue);
        },
        hint: S.of(context).selectSurah,
        getLabel: (surahId) {
          final surah = data.suwar.firstWhere((s) => s.id == surahId);
          return '${surah.id}. ${surah.name}';
        },
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.focused)) {
                  return Theme.of(context).primaryColor;
                }
                return null;
              },
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            S.of(context).cancel,
            style: textTheme.bodyLarge,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.focused)) {
                  return Theme.of(context).primaryColor;
                }
                return null;
              },
            ),
          ),
          onPressed: _handleSaveSchedule,
          child: Text(S.of(context).save),
        ),
      ],
    );
  }
}
