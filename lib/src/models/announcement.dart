import 'dart:developer';
import 'dart:typed_data';

import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;

part 'announcement.g.dart';

@HiveType(typeId: 0)
class Announcement {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? content;
  @HiveField(3)
  final int? duration;
  @HiveField(4)
  final DateTime? startDate;
  @HiveField(5)
  final String? updatedDate;
  @HiveField(6)
  final DateTime? endDate;
  @HiveField(7)
  final bool isMobile;
  @HiveField(8)
  final bool isDesktop;
  @HiveField(9)
  final String? image;
  @HiveField(10)
  final String? video;
  @HiveField(11)
  final Uint8List? imageFile;

//<editor-fold desc="Data Methods">

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.isMobile,
    required this.isDesktop,
    required this.image,
    required this.video,
    required this.duration,
    this.startDate,
    this.endDate,
    this.imageFile,
    required this.updatedDate,
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
          imageFile == other.imageFile &&
          video == other.video);

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      content.hashCode ^
      isMobile.hashCode ^
      isDesktop.hashCode ^
      imageFile.hashCode ^
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
    Uint8List? imageFile,
    String? image,
    String? video,
    int? duration,
    String? startDate,
    String? updatedDa,
    String? endDate,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isMobile: isMobile ?? this.isMobile,
      isDesktop: isDesktop ?? this.isDesktop,
      image: image ?? this.image,
      video: video ?? this.video,
      imageFile: imageFile ?? this.imageFile,
      duration: this.duration,
      startDate: this.startDate,
      endDate: this.endDate,
      updatedDate: this.updatedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'content': this.content,
      'isMobile': this.isMobile,
      'isDesktop': this.isDesktop,
      'imageFile': this.imageFile,
      'image': this.image,
      'video': this.video,
      "duration": this.duration,
      'startDate': this.startDate,
      'endDate': this.endDate,
      'updated': this.updatedDate,
    };
  }

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'],
      title: map['title'] ?? '',
      content: map['content'],
      isMobile: map['isMobile'] ?? false,
      isDesktop: map['isDesktop'] ?? true,
      image: map['image'],
      imageFile: map['imageFile'],
      video: map['video'],
      duration: map["duration"],
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      updatedDate: map['updated'],
    );
  }

  static List<Announcement> fromList(List? data) {
    return data == null ? [] : data.map((e) => Announcement.fromMap(e)).toList();
  }

  /// [isCacheable] returns true if the object can be cached
  /// if the announcement has a video it should not be cached
  bool get isCacheable => video == null;
}
