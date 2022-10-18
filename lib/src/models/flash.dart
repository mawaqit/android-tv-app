class Flash {
  final String content;
  final String orientation;
  final int expire;

//<editor-fold desc="Data Methods">

  const Flash({
    required this.content,
    required this.orientation,
    required this.expire,
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
  }) {
    return Flash(
      content: content ?? this.content,
      orientation: orientation ?? this.orientation,
      expire: expire ?? this.expire,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': this.content,
      'orientation': this.orientation,
      'expire': this.expire,
    };
  }

  factory Flash.fromMap(Map<String, dynamic> map) {
    return Flash(
      content: map['content'],
      orientation: map['orientation'],
      expire: map['expire'] ?? 0,
    );
  }

//</editor-fold>
}
