import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_sphere/features/auth/domain/entities/auth_entity.dart';

final profileEditorProvider =
    StateNotifierProvider<ProfileEditorNotifier, ProfileEditorState>(
  (ref) => ProfileEditorNotifier(),
);

class ProfileEditorState {
  final String fullName;
  final String email;
  final String studentId;
  final String phone;
  final String department;
  final String bio;
  final Uint8List? profileImageBytes;
  final String? profileImageName;
  final bool initialized;

  const ProfileEditorState({
    required this.fullName,
    required this.email,
    required this.studentId,
    required this.phone,
    required this.department,
    required this.bio,
    required this.profileImageBytes,
    required this.profileImageName,
    required this.initialized,
  });

  const ProfileEditorState.initial()
      : fullName = '',
        email = '',
        studentId = '',
        phone = '',
        department = 'Computer Science',
        bio = 'Passionate about campus events and student communities.',
        profileImageBytes = null,
        profileImageName = null,
        initialized = false;

  ProfileEditorState copyWith({
    String? fullName,
    String? email,
    String? studentId,
    String? phone,
    String? department,
    String? bio,
    Uint8List? profileImageBytes,
    String? profileImageName,
    bool clearProfileImage = false,
    bool? initialized,
  }) {
    return ProfileEditorState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      bio: bio ?? this.bio,
      profileImageBytes:
          clearProfileImage ? null : (profileImageBytes ?? this.profileImageBytes),
      profileImageName:
          clearProfileImage ? null : (profileImageName ?? this.profileImageName),
      initialized: initialized ?? this.initialized,
    );
  }
}

class ProfileEditorNotifier extends StateNotifier<ProfileEditorState> {
  static const String _profileStorageKey = 'profile_editor_state';

  ProfileEditorNotifier() : super(const ProfileEditorState.initial());

  Future<void> initializeFromUser(AuthEntity? user) async {
    if (state.initialized) return;

    state = state.copyWith(
      fullName: user?.name ?? 'Student User',
      email: user?.email ?? 'student@university.edu',
      phone: user?.phone ?? '',
      studentId: 'UNI-2026-001',
      initialized: true,
    );

    await _loadPersistedProfile();
  }

  Future<void> saveProfile({
    required String fullName,
    required String email,
    required String studentId,
    required String phone,
    required String department,
    required String bio,
  }) async {
    state = state.copyWith(
      fullName: fullName,
      email: email,
      studentId: studentId,
      phone: phone,
      department: department,
      bio: bio,
      initialized: true,
    );

    await _persistProfile();
  }

  Future<void> updateProfileImage(Uint8List imageBytes, String fileName) async {
    state = state.copyWith(
      profileImageBytes: imageBytes,
      profileImageName: fileName,
      initialized: true,
    );

    await _persistProfile();
  }

  Future<void> reset() async {
    state = const ProfileEditorState.initial();
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_profileStorageKey);
  }

  Future<void> _loadPersistedProfile() async {
    final preferences = await SharedPreferences.getInstance();
    final savedProfile = preferences.getString(_profileStorageKey);

    if (savedProfile == null || savedProfile.isEmpty) {
      return;
    }

    final data = jsonDecode(savedProfile) as Map<String, dynamic>;
    final imageBase64 = data['profileImageBase64'] as String?;

    state = state.copyWith(
      fullName: data['fullName'] as String?,
      email: data['email'] as String?,
      studentId: data['studentId'] as String?,
      phone: data['phone'] as String?,
      department: data['department'] as String?,
      bio: data['bio'] as String?,
      profileImageBytes:
          imageBase64 == null ? null : Uint8List.fromList(base64Decode(imageBase64)),
      profileImageName: data['profileImageName'] as String?,
      clearProfileImage: imageBase64 == null,
      initialized: true,
    );
  }

  Future<void> _persistProfile() async {
    final preferences = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'fullName': state.fullName,
      'email': state.email,
      'studentId': state.studentId,
      'phone': state.phone,
      'department': state.department,
      'bio': state.bio,
      'profileImageName': state.profileImageName,
      'profileImageBase64': state.profileImageBytes == null
          ? null
          : base64Encode(state.profileImageBytes!),
    };

    await preferences.setString(_profileStorageKey, jsonEncode(payload));
  }
}
