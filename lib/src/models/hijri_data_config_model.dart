import 'package:equatable/equatable.dart';

/// [HijriDateConfigModel] Represents the Hijri date configuration for a mosque.
class HijriDateConfigModel extends Equatable {
  /// The adjustment value for the Hijri date.
  int hijriAdjustment;

  ///[hijriDateForceTo30]Flag indicating whether to force the Hijri date to 30 days.
  bool hijriDateForceTo30;

  HijriDateConfigModel({
    required this.hijriAdjustment,
    required this.hijriDateForceTo30,
  });

  /// Creates an instance of [HijriDateConfigModel] from a JSON map.
  factory HijriDateConfigModel.fromJson(Map<String, dynamic> json) {
    return HijriDateConfigModel(
      hijriAdjustment: json['hijriAdjustment'],
      hijriDateForceTo30: json['hijriDateForceTo30'],
    );
  }

  /// Converts the instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'hijriAdjustment': hijriAdjustment,
      'hijriDateForceTo30': hijriDateForceTo30,
    };
  }

  /// Creates a copy of the instance with the given override values.
  HijriDateConfigModel copyWith({
    int? hijriAdjustment,
    bool? hijriDateForceTo30,
  }) {
    return HijriDateConfigModel(
      hijriAdjustment: hijriAdjustment ?? this.hijriAdjustment,
      hijriDateForceTo30: hijriDateForceTo30 ?? this.hijriDateForceTo30,
    );
  }

  /// Returns list of properties to be used for value comparison.
  @override
  List<Object> get props => [hijriAdjustment, hijriDateForceTo30];
}
