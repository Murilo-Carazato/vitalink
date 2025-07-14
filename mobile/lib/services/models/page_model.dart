// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PageModel {
  int label;
  bool active;
  PageModel({
    required this.label,
    required this.active,
  });

  PageModel copyWith({
    int? label,
    bool? active,
  }) {
    return PageModel(
      label: label ?? this.label,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'label': label,
      'active': active,
    };
  }

  factory PageModel.fromMap(Map<String, dynamic> map) {
    return PageModel(
      label: map['label'] as int,
      active: map['active'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory PageModel.fromJson(String source) => PageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'PageModel(label: $label, active: $active)';

  @override
  bool operator ==(covariant PageModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.label == label &&
      other.active == active;
  }

  @override
  int get hashCode => label.hashCode ^ active.hashCode;
}
