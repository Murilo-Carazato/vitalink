// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:vitalink/services/models/blood_center_model.dart';

class NearbyModel {
  final double distance; 
  final BloodCenterModel bloodCenter;
  NearbyModel({
    required this.distance,
    required this.bloodCenter,
  });

  NearbyModel copyWith({
    double? distance,
    BloodCenterModel? bloodCenter,
  }) {
    return NearbyModel(
      distance: distance ?? this.distance,
      bloodCenter: bloodCenter ?? this.bloodCenter,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'distance': distance,
      'bloodCenter': bloodCenter.toMap(),
    };
  }

  factory NearbyModel.fromMap(Map<String, dynamic> map) {
    return NearbyModel(
      distance: map['distance'] as double,
      bloodCenter: BloodCenterModel.fromMap(map['bloodCenter'] as Map<String,dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory NearbyModel.fromJson(String source) => NearbyModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'NearbyModel(distance: $distance, bloodCenter: $bloodCenter)';

  @override
  bool operator ==(covariant NearbyModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.distance == distance &&
      other.bloodCenter == bloodCenter;
  }

  @override
  int get hashCode => distance.hashCode ^ bloodCenter.hashCode;
}
