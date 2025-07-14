import 'dart:convert';

class RegisterRequest {
  final String email;
  final String password;
  final String? isadmin;
  final int? bloodcenterId;

  RegisterRequest({
    required this.email,
    required this.password,
    this.isadmin,
    this.bloodcenterId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'password': password,
      if (isadmin != null) 'isadmin': isadmin,
      if (bloodcenterId != null) 'bloodcenter_id': bloodcenterId,
    };
  }

  String toJson() => json.encode(toMap());
}