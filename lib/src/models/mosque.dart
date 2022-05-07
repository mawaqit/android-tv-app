class Mosque {
  final String? jumua;

  // final String? proximity;
  final String? label;
  final String? localisation;
  final String? image;
  final String? jumua2;
  final bool? jumuaAsDuhr;

  // final int id;
  final String uuid;
  final String name;
  final String slug;

  final double? latitude;
  final double? longitude;
  final String? associationName;
  final String? phone;
  final String? paymentWebsite;
  final String? email;
  final String? site;

  // final String? closed;
  final bool? womenSpace;
  final bool? janazaPrayer;
  final bool? aidPrayer;
  final bool? childrenCourses;
  final bool? adultCourses;
  final bool? ramadanMeal;
  final bool? handicapAccessibility;
  final bool? ablutions;
  final bool? parking;
  final List<String>? times;
  final List<String>? iqama;

  Mosque(
      {this.jumua,
      this.label,
      this.localisation,
      this.image,
      this.jumua2,
      this.jumuaAsDuhr,
      required this.uuid,
      required this.name,
      required this.slug,
      this.latitude,
      this.longitude,
      this.associationName,
      this.phone,
      this.paymentWebsite,
      this.email,
      this.site,
      this.womenSpace,
      this.janazaPrayer,
      this.aidPrayer,
      this.childrenCourses,
      this.adultCourses,
      this.ramadanMeal,
      this.handicapAccessibility,
      this.ablutions,
      this.parking,
      this.times,
      this.iqama});

  Map<String, dynamic> toMap() {
    return {
      'jumua': this.jumua,
      'label': this.label,
      'localisation': this.localisation,
      'image': this.image,
      'jumua2': this.jumua2,
      'jumuaAsDuhr': this.jumuaAsDuhr,
      'uuid': this.uuid,
      'name': this.name,
      'slug': this.slug,
      'latitude': this.latitude,
      'longitude': this.longitude,
      'associationName': this.associationName,
      'phone': this.phone,
      'paymentWebsite': this.paymentWebsite,
      'email': this.email,
      'site': this.site,
      'womenSpace': this.womenSpace,
      'janazaPrayer': this.janazaPrayer,
      'aidPrayer': this.aidPrayer,
      'childrenCourses': this.childrenCourses,
      'adultCourses': this.adultCourses,
      'ramadanMeal': this.ramadanMeal,
      'handicapAccessibility': this.handicapAccessibility,
      'ablutions': this.ablutions,
      'parking': this.parking,
      'times': this.times,
      'iqama': this.iqama,
    };
  }

  factory Mosque.fromMap(Map<String, dynamic> map) {
    return Mosque(
      jumua: map['jumua'],
      label: map['label'],
      localisation: map['localisation'],
      image: map['image'],
      jumua2: map['jumua2'],
      jumuaAsDuhr: map['jumuaAsDuhr'],
      uuid: map['uuid'],
      name: map['name'],
      slug: map['slug'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      associationName: map['associationName'],
      phone: map['phone'],
      paymentWebsite: map['paymentWebsite'],
      email: map['email'],
      site: map['site'],
      womenSpace: map['womenSpace'],
      janazaPrayer: map['janazaPrayer'],
      aidPrayer: map['aidPrayer'],
      childrenCourses: map['childrenCourses'],
      adultCourses: map['adultCourses'],
      ramadanMeal: map['ramadanMeal'],
      handicapAccessibility: map['handicapAccessibility'],
      ablutions: map['ablutions'],
      parking: map['parking'],
      times: map['times'].cast<String>(),
      iqama: map['iqama'].cast<String>(),
    );
  }
}
