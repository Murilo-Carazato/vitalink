// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

/*
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(255) NOT NULL,
  `content` TEXT NOT NULL,
  `image` LONGTEXT NULL DEFAULT NULL,
  `type` ENUM('campaing', 'emergency') NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
*/

class NewsModel {
  final int id;
  final int userId;
  final String title;
  final String content;
  final String? image;
  final String type; //enum
  final String? createdAt;
  final String? updatedAt;
  final String? bloodType;

  NewsModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.image,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.bloodType,
  });

  NewsModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? content,
    String? image,
    String? type,
    String? createdAt,
    String? updatedAt,
    String? bloodType,
  }) {
    return NewsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      image: image ?? this.image,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bloodType: bloodType ?? this.bloodType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'image': image,
      'type': type,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'bloodType': bloodType,
    };
  }

  factory NewsModel.fromMap(Map<String, dynamic> map) {
    return NewsModel(
      id: map['id'] as int,
      title: map['title'] as String,
      content: map['content'] as String,
      image: map['image'] != null ? map['image'] as String : null,
      type: map['type'] as String,
      userId: map['user_id'] as int,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      bloodType: map['blood_type'] != null ? map['blood_type'] as String : null, // <-- Adicione aqui
    );
  }

  String toJson() => json.encode(toMap());

  factory NewsModel.fromJson(String source) => NewsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NewsModel(id: $id, userId: $userId, title: $title, content: $content, image: $image, type: $type, createdAt: $createdAt, updatedAt: $updatedAt, bloodType: $bloodType)';
  }
}
