class Mosque {
  final int id;
  final String uuid;
  final String name;
  final String slug;
  final String image;
  final String? location;

//<editor-fold desc="Data Methods">

  const Mosque({
    required this.id,
    required this.uuid,
    required this.name,
    required this.slug,
    required this.image,
    this.location,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mosque &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          uuid == other.uuid &&
          name == other.name &&
          slug == other.slug &&
          image == other.image &&
          location == other.location);

  @override
  int get hashCode => id.hashCode ^ uuid.hashCode ^ name.hashCode ^ slug.hashCode ^ image.hashCode ^ location.hashCode;

  @override
  String toString() {
    return 'Mosque{' +
        ' id: $id,' +
        ' uuid: $uuid,' +
        ' name: $name,' +
        ' slug: $slug,' +
        ' image: $image,' +
        ' location: $location,' +
        '}';
  }

  Mosque copyWith({
    int? id,
    String? uuid,
    String? name,
    String? slug,
    String? image,
    String? location,
  }) {
    return Mosque(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      image: image ?? this.image,
      location: location ?? this.location,
    );
  }

  factory Mosque.fromMap(Map<String, dynamic> map) {
    return Mosque(
      id: map['id'] ?? 0,
      uuid: map['uuid'],
      name: map['name'],
      slug: map['slug'],
      image: map['image'],
      location: map['localisation'],
    );
  }

//</editor-fold>
}
