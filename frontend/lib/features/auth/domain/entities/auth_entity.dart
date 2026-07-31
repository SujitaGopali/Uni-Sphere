import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String role;
  final String? username;
  final String? studentId;
  final String? college;
  final String? department;
  final String? phoneNumber;
  final String? year;
  final String? interests;
  final String? verificationStatus;
  final String? profileImage;

  const AuthEntity({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.password = '',
    this.role = 'user',
    this.username,
    this.studentId,
    this.college,
    this.department,
    this.phoneNumber,
    this.year,
    this.interests,
    this.verificationStatus,
    this.profileImage,
  });

  /// Legacy convenience for older screens.
  String get name {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? 'User' : full;
  }

  String get phone => phoneNumber ?? '';
  String get address => college ?? '';

  factory AuthEntity.fromJson(Map<String, dynamic> json) {
    final first = (json['firstName'] as String?)?.trim() ?? '';
    final last = (json['lastName'] as String?)?.trim() ?? '';
    final legacyName = (json['name'] as String?)?.trim() ?? '';
    String resolvedFirst = first;
    String resolvedLast = last;
    if (resolvedFirst.isEmpty && legacyName.isNotEmpty) {
      final parts = legacyName.split(RegExp(r'\s+'));
      resolvedFirst = parts.first;
      resolvedLast = parts.length > 1 ? parts.sublist(1).join(' ') : 'User';
    }
    return AuthEntity(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      firstName: resolvedFirst.isEmpty ? 'User' : resolvedFirst,
      lastName: resolvedLast,
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      username: json['username']?.toString(),
      studentId: json['studentId']?.toString(),
      college: json['college']?.toString(),
      department: json['department']?.toString(),
      phoneNumber: json['phoneNumber']?.toString() ?? json['phone']?.toString(),
      year: json['year']?.toString(),
      interests: json['interests']?.toString(),
      verificationStatus: json['verificationStatus']?.toString() ?? 'none',
      profileImage: json['profileImage']?.toString(),
    );
  }

  Map<String, dynamic> toRegisterJson() {
    final uname = username ??
        '${email.split('@').first.substring(0, email.split('@').first.length.clamp(0, 12))}${DateTime.now().millisecond}';
    return {
      'firstName': firstName,
      'lastName': lastName.isEmpty ? 'User' : lastName,
      'email': email,
      'username': uname,
      'studentId': studentId ?? 'STU-${DateTime.now().millisecondsSinceEpoch}',
      'password': password,
      'role': role,
      if (college != null && college!.isNotEmpty) 'college': college,
    };
  }

  AuthEntity copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? role,
    String? username,
    String? studentId,
    String? college,
    String? department,
    String? phoneNumber,
    String? year,
    String? interests,
    String? verificationStatus,
    String? profileImage,
  }) {
    return AuthEntity(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      username: username ?? this.username,
      studentId: studentId ?? this.studentId,
      college: college ?? this.college,
      department: department ?? this.department,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      year: year ?? this.year,
      interests: interests ?? this.interests,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        role,
        college,
        verificationStatus,
        profileImage,
      ];
}
