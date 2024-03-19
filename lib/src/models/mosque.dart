import 'package:equatable/equatable.dart';
import 'package:mawaqit/src/models/flash.dart';

import '../const/constants.dart';
import 'announcement.dart';

class Mosque extends Equatable{
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

  final String? streamUrl;

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
    required this.streamUrl,
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

  factory Mosque.fromMap(Map<String, dynamic> map) {
    print('[Mosque UUID] ${map['uuid']}');
    return Mosque(
      id: map['id'] ?? -1,
      uuid: map['uuid'],
      name: map['name'],
      label: map['label'],
      email: map['email'],
      phone: map['phone'],
      url: map['url'],
      type: map["type"] == null ? "MOSQUE" : map['type'],
      image: map['image'] ?? kDefaultMosqueImage,
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
      streamUrl: map['streamUrl'] == '' ? null : map['streamUrl'],
    );
  }

  @override
  List get props => [id];
//</editor-fold>
}
