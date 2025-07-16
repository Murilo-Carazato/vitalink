// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:flutter/material.dart';

class UserModel {
  final int id;
  final String name;
  final bool viewedTutorial;
  final bool hasTattoo;
  final bool hasMicropigmentation;
  final bool hasPermanentMakeup;

  final String? birthDate;
  final String? bloodType;
  final String? email;
  final String? token;
  final String? profilePhotoPath;
  final String? themeMode;

  UserModel({
    required this.id,
    required this.name,
    this.birthDate = '',
    this.bloodType = '',
    this.viewedTutorial = false,
    this.hasTattoo = false,
    this.hasMicropigmentation = false,
    this.hasPermanentMakeup = false,
    this.email,
    this.token,
    this.profilePhotoPath,
    this.themeMode = 'dark',
  });

  //O código a seguir sobrescreve o operador "==". Sendo assim, compara duas instâncias e verifica se são iguais.
  //Se isso não for realizado, o Dart não é capaz de comparar se duas instâncias do mesmo tipo são iguais, pois a referência de memória é diferente.
  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.birthDate == birthDate &&
        other.bloodType == bloodType &&
        other.viewedTutorial == viewedTutorial &&
        other.hasTattoo == hasTattoo &&
        other.hasMicropigmentation == hasMicropigmentation &&
        other.hasPermanentMakeup == hasPermanentMakeup &&
        other.email == email &&
        other.token == token &&
        other.themeMode == themeMode &&
        other.profilePhotoPath == profilePhotoPath;
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? birthDate,
    String? bloodType,
    bool? viewedTutorial,
    bool? hasTattoo,
    bool? hasMicropigmentation,
    bool? hasPermanentMakeup,
    String? email,
    String? token,
    String? profilePhotoPath,
    String? themeMode,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      bloodType: bloodType ?? this.bloodType,
      viewedTutorial: viewedTutorial ?? this.viewedTutorial,
      hasTattoo: hasTattoo ?? this.hasTattoo,
      hasMicropigmentation: hasMicropigmentation ?? this.hasMicropigmentation,
      hasPermanentMakeup: hasPermanentMakeup ?? this.hasPermanentMakeup,
      email: email ?? this.email,
      token: token ?? this.token,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'birthDate': birthDate,
      'bloodType': bloodType,
      'viewedTutorial': viewedTutorial ? 1 : 0,
      'hasTattoo': hasTattoo ? 1 : 0,
      'hasMicropigmentation': hasMicropigmentation ? 1 : 0,
      'hasPermanentMakeup': hasPermanentMakeup ? 1 : 0,
      'email': email,
      'token': token,
      'profile_photo_path': profilePhotoPath,
      'theme_mode': themeMode,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      name: map['name'] ?? '',
      birthDate: map['birthDate'] ?? '',
      bloodType: map['bloodType'] ?? '',
      viewedTutorial: (map['viewedTutorial'] ?? 0) == 1,
      hasTattoo: (map['hasTattoo'] ?? 0) == 1,
      hasMicropigmentation: (map['hasMicropigmentation'] ?? 0) == 1,
      hasPermanentMakeup: (map['hasPermanentMakeup'] ?? 0) == 1,
      email: map['email'],
      token: map['token'],
      profilePhotoPath: map['profile_photo_path'] as String?,
      themeMode: map['theme_mode'] ?? 'dark',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, birthDate: $birthDate, bloodType: $bloodType, viewedTutorial: $viewedTutorial, hasTattoo: $hasTattoo, hasMicropigmentation: $hasMicropigmentation, hasPermanentMakeup: $hasPermanentMakeup, email: $email, token: $token, profilePhotoPath: $profilePhotoPath, themeMode: $themeMode)';
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        birthDate.hashCode ^
        bloodType.hashCode ^
        viewedTutorial.hashCode ^
        hasTattoo.hashCode ^
        hasMicropigmentation.hashCode ^
        hasPermanentMakeup.hashCode ^
        email.hashCode ^
        token.hashCode ^
        profilePhotoPath.hashCode ^
        themeMode.hashCode;
  }

  // Converte a string do tema para o enum ThemeMode do Flutter
  ThemeMode getThemeMode() {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark; // Valor padrão
    }
  }
}
