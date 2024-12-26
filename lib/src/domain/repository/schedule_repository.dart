import 'package:mawaqit/src/domain/model/schedule_model.dart';

abstract class ScheduleRepository {
  Future<ScheduleModel> getSchedule();
  Future<void> saveSchedule(ScheduleModel schedule);
  Future<void> disableSchedule();
  Future<List<String>> generateRandomUrls(ScheduleModel schedule);
  Future<void> updateBackgroundService();
}
