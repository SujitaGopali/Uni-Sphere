import 'package:uni_sphere/features/auth/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String id,
    required String fullName,
    required String email,
    required String password,
    required DateTime createdAt,
  }) : super(
         id: id,
         fullName: fullName,
         email: email,
         password: password,
         createdAt: createdAt,
       );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
