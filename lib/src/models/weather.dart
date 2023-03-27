class Weather {
  final int temperature;
  final String? feeling;
  final String icon;

//<editor-fold desc="Data Methods">

  const Weather({
    required this.temperature,
    this.feeling,
    required this.icon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Weather &&
          runtimeType == other.runtimeType &&
          temperature == other.temperature &&
          feeling == other.feeling &&
          icon == other.icon);

  @override
  int get hashCode => temperature.hashCode ^ feeling.hashCode ^ icon.hashCode;

  @override
  String toString() {
    return 'Weather{' +
        ' temperature: $temperature,' +
        ' feeling: $feeling,' +
        ' icon: $icon,' +
        '}';
  }

  Weather copyWith({
    int? temperature,
    String? feeling,
    String? icon,
  }) {
    return Weather(
      temperature: temperature ?? this.temperature,
      feeling: feeling ?? this.feeling,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'temperature': this.temperature,
      'feeling': this.feeling,
      'icon': this.icon,
    };
  }

  factory Weather.fromMap(Map<String, dynamic> map) {
    return Weather(
      temperature: map['temperature'] as int,
      feeling: map['feeling'] as String,
      icon: map['icon'] as String,
    );
  }

//</editor-fold>
}
