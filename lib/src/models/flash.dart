class Flash {
  final String content;
  final String orientation;
  final int expire;
  final String? startDate;
  final String? endDate;
  final String? color;


//<editor-fold desc="Data Methods">

  const Flash({
    required this.content,
    required this.orientation,
    required this.expire,
    required this.endDate,
    required this.startDate,
    required this.color,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Flash &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          orientation == other.orientation &&
          expire == other.expire);

  @override
  int get hashCode => content.hashCode ^ orientation.hashCode ^ expire.hashCode;

  @override
  String toString() {
    return 'Flash{' + ' content: $content,' + ' orientation: $orientation,' + ' expire: $expire,' + '}';
  }

  Flash copyWith({
    String? content,
    String? orientation,
    int? expire,
    String? color,
    String? startDate,
    String? endDate,
  }) {
    return Flash(
      content: content ?? this.content,
      orientation: orientation ?? this.orientation,
      expire: expire ?? this.expire,
      color: color ?? this.color,
      startDate: startDate?? this.startDate,
      endDate: endDate??this.endDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': this.content,
      'orientation': this.orientation,
      'expire': this.expire,
      'startDate':this.startDate,
      'endDate': this.endDate,
      'color': this.color,
    };
  }

  factory Flash.fromMap(Map<String, dynamic> map) {
    return Flash(
      content: map['content'],
      orientation: map['orientation'],
      expire: map['expire'] ?? 0,
      color: map['color'],
        startDate: map['startDate'],
      endDate: map['endDate'],

    );
  }

//</editor-fold>
}
