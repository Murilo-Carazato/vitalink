import 'dart:convert';

class BloodCenterModel {
  final int id;
  final String name;
  final String address;
  final String? phoneNumber;
  final String? email;
  final String? site;
  final double latitude;
  final double longitude;
  final String createdAt;
  final String updatedAt;

  BloodCenterModel({
    required this.id,
    required this.name,
    required this.address,
    this.phoneNumber,
    this.email,
    this.site,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  BloodCenterModel copyWith({
    int? id,
    String? name,
    String? address,
    String? phoneNumber,
    String? email,
    String? site,
    double? latitude,
    double? longitude,
    String? createdAt,
    String? updatedAt,
  }) {
    return BloodCenterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      site: site ?? this.site,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'address': address,
      'phone_number': phoneNumber,
      'email': email,
      'site': site,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory BloodCenterModel.fromMap(Map<String, dynamic> map, {bool isFromApi = true}) {
    return BloodCenterModel(
      id: map['id'] as int,
      name: map['name'] as String,
      address: map['address'] as String,
      phoneNumber: map['phone_number'] as String?,
      email: map['email'] as String?,
      site: map['site'] as String?,
      latitude: map['latitude'] is double ? map['latitude'] : (map['latitude'] as num).toDouble(),
      longitude: map['longitude'] is double ? map['longitude'] : (map['longitude'] as num).toDouble(),
      createdAt: map['created_at'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory BloodCenterModel.fromJson(String source) =>
      BloodCenterModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BloodCenterModel(id: $id, name: $name, address: $address, phoneNumber: $phoneNumber, email: $email, site: $site, latitude: $latitude, longitude: $longitude, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant BloodCenterModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.address == address &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.site == site &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        address.hashCode ^
        phoneNumber.hashCode ^
        email.hashCode ^
        site.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}