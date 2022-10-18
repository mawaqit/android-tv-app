class Announcement {
  final int id;
  final String title;
  final String? content;
  final bool isMobile;
  final bool isDesktop;
  final String? image;
  final String? video;

//<editor-fold desc="Data Methods">

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.isMobile,
    required this.isDesktop,
    required this.image,
    required this.video,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Announcement &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          content == other.content &&
          isMobile == other.isMobile &&
          isDesktop == other.isDesktop &&
          image == other.image &&
          video == other.video);

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      content.hashCode ^
      isMobile.hashCode ^
      isDesktop.hashCode ^
      image.hashCode ^
      video.hashCode;

  @override
  String toString() {
    return 'Announcement{' +
        ' id: $id,' +
        ' title: $title,' +
        ' content: $content,' +
        ' isMobile: $isMobile,' +
        ' isDesktop: $isDesktop,' +
        ' image: $image,' +
        ' video: $video,' +
        '}';
  }

  Announcement copyWith({
    int? id,
    String? title,
    String? content,
    bool? isMobile,
    bool? isDesktop,
    String? image,
    String? video,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isMobile: isMobile ?? this.isMobile,
      isDesktop: isDesktop ?? this.isDesktop,
      image: image ?? this.image,
      video: video ?? this.video,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'content': this.content,
      'isMobile': this.isMobile,
      'isDesktop': this.isDesktop,
      'image': this.image,
      'video': this.video,
    };
  }

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      isMobile: map['isMobile'],
      isDesktop: map['isDesktop'],
      image: map['image'],
      video: map['video'],
    );
  }

  static List<Announcement> fromList(List data) {
    return data.map((e) => Announcement.fromMap(e)).toList();
  }

//</editor-fold>
}
