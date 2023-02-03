import 'package:flutter/cupertino.dart';
import 'package:mawaqit/src/models/flash.dart';

import 'announcement.dart';

class Mosque {
  final int id;
  final String? uuid;
  final String? type;

  final String name;
  final String? label;
  final String? email;
  final String? phone;
  final String? url;
  final String? image;
  final String? interiorPicture;
  final String? exteriorPicture;
  final String? logo;
  final String? site;
  final String? countryCode;
  final String? association;
  final String? localisation;
  final num? longitude;
  final num? latitude;
  final String? closed;
  final bool? womenSpace;
  final bool? janazaPrayer;
  final bool? aidPrayer;
  final bool? childrenCourses;
  final bool? adultCourses;
  final bool? ramadanMeal;
  final bool? handicapAccessibility;
  final bool? ablutions;
  final bool? parking;
  final String? otherInfo;
  final String? flashMessage;
  final Flash? flash;
  final List<Announcement> announcements;

//<editor-fold desc="Data Methods">

  const Mosque({
    required this.id,
    required this.uuid,
    required this.name,
    required this.type,
    required this.label,
    required this.email,
    required this.phone,
    required this.url,
    required this.image,
    required this.logo,
    required this.countryCode,
    required this.site,
    required this.association,
    required this.localisation,
    required this.longitude,
    required this.latitude,
    required this.closed,
    required this.womenSpace,
    required this.janazaPrayer,
    required this.aidPrayer,
    required this.childrenCourses,
    required this.adultCourses,
    required this.ramadanMeal,
    required this.handicapAccessibility,
    required this.ablutions,
    required this.parking,
    required this.otherInfo,
    required this.flashMessage,
    required this.flash,
    required this.announcements,
    required this.interiorPicture,
    required this.exteriorPicture,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mosque &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          uuid == other.uuid &&
          name == other.name &&
          email == other.email &&
          phone == other.phone &&
          url == other.url &&
          image == other.image &&
          site == other.site &&
          association == other.association &&
          localisation == other.localisation &&
          longitude == other.longitude &&
          latitude == other.latitude &&
          closed == other.closed &&
          womenSpace == other.womenSpace &&
          janazaPrayer == other.janazaPrayer &&
          aidPrayer == other.aidPrayer &&
          childrenCourses == other.childrenCourses &&
          adultCourses == other.adultCourses &&
          ramadanMeal == other.ramadanMeal &&
          handicapAccessibility == other.handicapAccessibility &&
          ablutions == other.ablutions &&
          parking == other.parking &&
          otherInfo == other.otherInfo &&
          flashMessage == other.flashMessage &&
          flash == other.flash &&
          announcements == other.announcements);

  @override
  int get hashCode =>
      id.hashCode ^
      uuid.hashCode ^
      name.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      url.hashCode ^
      image.hashCode ^
      site.hashCode ^
      association.hashCode ^
      localisation.hashCode ^
      longitude.hashCode ^
      latitude.hashCode ^
      closed.hashCode ^
      womenSpace.hashCode ^
      janazaPrayer.hashCode ^
      aidPrayer.hashCode ^
      childrenCourses.hashCode ^
      adultCourses.hashCode ^
      ramadanMeal.hashCode ^
      handicapAccessibility.hashCode ^
      ablutions.hashCode ^
      parking.hashCode ^
      otherInfo.hashCode ^
      flashMessage.hashCode ^
      flash.hashCode ^
      announcements.hashCode;

  @override
  String toString() {
    return 'Mosque{' +
        ' id: $id,' +
        ' uuid: $uuid,' +
        ' name: $name,' +
        ' email: $email,' +
        ' phone: $phone,' +
        ' url: $url,' +
        ' image: $image,' +
        ' site: $site,' +
        ' association: $association,' +
        ' localisation: $localisation,' +
        ' longitude: $longitude,' +
        ' latitude: $latitude,' +
        ' closed: $closed,' +
        ' womenSpace: $womenSpace,' +
        ' janazaPrayer: $janazaPrayer,' +
        ' aidPrayer: $aidPrayer,' +
        ' childrenCourses: $childrenCourses,' +
        ' adultCourses: $adultCourses,' +
        ' ramadanMeal: $ramadanMeal,' +
        ' handicapAccessibility: $handicapAccessibility,' +
        ' ablutions: $ablutions,' +
        ' parking: $parking,' +
        ' otherInfo: $otherInfo,' +
        ' flashMessage: $flashMessage,' +
        ' flash: $flash,' +
        ' announcements: $announcements,' +
        '}';
  }

  Mosque copyWith({
    int? id,
    String? uuid,
    String? name,
    String? label,
    String? type,
    String? email,
    String? phone,
    String? url,
    String? image,
    String? interiorPicture,
    String? exteriorPicture,
    String? logo,
    String? countryCode,
    String? site,
    String? association,
    String? localisation,
    num? longitude,
    num? latitude,
    String? closed,
    bool? womenSpace,
    bool? janazaPrayer,
    bool? aidPrayer,
    bool? childrenCourses,
    bool? adultCourses,
    bool? ramadanMeal,
    bool? handicapAccessibility,
    bool? ablutions,
    bool? parking,
    String? otherInfo,
    String? flashMessage,
    Flash? flash,
    List<Announcement>? announcements,
  }) {
    return Mosque(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      type: name ?? this.type,
      label: label ?? this.label,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      url: url ?? this.url,
      image: image ?? this.image,
      interiorPicture: interiorPicture ?? this.interiorPicture,
      exteriorPicture: exteriorPicture ?? this.exteriorPicture,
      logo: logo ?? this.logo,
      countryCode: countryCode ?? this.countryCode,
      site: site ?? this.site,
      association: association ?? this.association,
      localisation: localisation ?? this.localisation,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      closed: closed ?? this.closed,
      womenSpace: womenSpace ?? this.womenSpace,
      janazaPrayer: janazaPrayer ?? this.janazaPrayer,
      aidPrayer: aidPrayer ?? this.aidPrayer,
      childrenCourses: childrenCourses ?? this.childrenCourses,
      adultCourses: adultCourses ?? this.adultCourses,
      ramadanMeal: ramadanMeal ?? this.ramadanMeal,
      handicapAccessibility:
          handicapAccessibility ?? this.handicapAccessibility,
      ablutions: ablutions ?? this.ablutions,
      parking: parking ?? this.parking,
      otherInfo: otherInfo ?? this.otherInfo,
      flashMessage: flashMessage ?? this.flashMessage,
      flash: flash ?? this.flash,
      announcements: announcements ?? this.announcements,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'uuid': this.uuid,
      'name': this.name,
      'email': this.email,
      'phone': this.phone,
      'url': this.url,
      'type': this.type,
      'image': this.image,
      'label': this.label,
      'logo': this.logo,
      'interiorPicture': this.interiorPicture,
      'exteriorPicture': this.exteriorPicture,
      'countryCode': this.countryCode,
      'site': this.site,
      'association': this.association,
      'localisation': this.localisation,
      'longitude': this.longitude,
      'latitude': this.latitude,
      'closed': this.closed,
      'womenSpace': this.womenSpace,
      'janazaPrayer': this.janazaPrayer,
      'aidPrayer': this.aidPrayer,
      'childrenCourses': this.childrenCourses,
      'adultCourses': this.adultCourses,
      'ramadanMeal': this.ramadanMeal,
      'handicapAccessibility': this.handicapAccessibility,
      'ablutions': this.ablutions,
      'parking': this.parking,
      'otherInfo': this.otherInfo,
      'flashMessage': this.flashMessage,
      'flash': this.flash,
      'announcements': this.announcements,
    };
  }

  factory Mosque.fromMap(Map<String, dynamic> map) {
    // debugPrint(map.toString(),wrapWidth: 500);
    return Mosque(
      id: map['id'] ?? -1,
      uuid: map['uuid'],
      name: map['name'],
      label: map['label'],
      email: map['email'],
      phone: map['phone'],
      url: map['url'],
      type: map["type"] == null ? "MOSQUE" : map['type'],
      image: map['image'],
      logo: map['logo'],
      interiorPicture: map['interiorPicture'],
      exteriorPicture: map['exteriorPicture'],
      countryCode: map['countryCode'],
      site: map['site'],
      association: map['association'],
      localisation: map['localisation'],
      longitude: map['longitude'],
      latitude: map['latitude'],
      closed: map['closed'],
      womenSpace: map['womenSpace'],
      janazaPrayer: map['janazaPrayer'],
      aidPrayer: map['aidPrayer'],
      childrenCourses: map['childrenCourses'],
      adultCourses: map['adultCourses'],
      ramadanMeal: map['ramadanMeal'],
      handicapAccessibility: map['handicapAccessibility'],
      ablutions: map['ablutions'],
      parking: map['parking'],
      otherInfo: map['otherInfo'],
      flashMessage: map['flashMessage'],
      flash: map['flash'] == null ? null : Flash.fromMap(map['flash']),
      announcements: Announcement.fromList(map['announcements']),
    );
  }

//</editor-fold>
}
