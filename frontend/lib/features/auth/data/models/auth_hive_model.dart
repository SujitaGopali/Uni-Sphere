import 'package:hive/hive.dart';
import 'package:uni_sphere/features/auth/domain/entities/auth_entity.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: 0)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String password;

  @HiveField(3)
  final String phone;

  @HiveField(4)
  final String address;

  AuthHiveModel({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
  });

  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      name: entity.name,
      email: entity.email,
      password: entity.password,
      phone: entity.phoneNumber ?? '',
      address: entity.college ?? '',
    );
  }

  AuthEntity toEntity() {
    final parts = name.trim().split(RegExp(r'\s+'));
    final first = parts.isNotEmpty ? parts.first : 'User';
    final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    return AuthEntity(
      firstName: first,
      lastName: last,
      email: email,
      password: password,
      phoneNumber: phone,
      college: address,
      role: 'user',
    );
  }
}
