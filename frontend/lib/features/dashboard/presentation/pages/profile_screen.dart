import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uni_sphere/core/api/api_endpoints.dart';
import 'package:uni_sphere/core/api/uni_api_service.dart';
import 'package:uni_sphere/core/constants/colleges.dart';
import 'package:uni_sphere/core/services/auto_brightness_provider.dart';
import 'package:uni_sphere/core/widgets/dash_widgets.dart';
import 'package:uni_sphere/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:uni_sphere/themes/app_colors.dart';
import 'package:uni_sphere/themes/app_theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  static const _years = ['1', '2', '3', '4'];

  bool _editing = false;
  bool _saving = false;
  bool _loadingSecurity = false;
  bool _changingPassword = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _dept = TextEditingController();
  final _studentId = TextEditingController();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  String? _college;
  String? _year;
  String? _pickedImagePath;
  List<Map<String, dynamic>> _history = [];
  List<Map<String, dynamic>> _sessions = [];
  bool _loginAlerts = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncFromUser();
      _loadSecurity();
    });
  }

  void _syncFromUser() {
    final user = ref.read(authViewModelProvider).user;
    if (user == null) return;
    _name.text = user.name;
    _email.text = user.email;
    _phone.text = user.phoneNumber ?? '';
    _dept.text = user.department ?? '';
    _studentId.text = user.studentId ?? '';
    _college = user.college;
    _year = user.year != null && _years.contains(user.year) ? user.year : user.year;
    _pickedImagePath = null;
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.dashCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.dashAccent),
              title: const Text(
                'Choose from gallery',
                style: TextStyle(
                  fontFamily: AppTheme.fontBold,
                  color: AppColors.dashText,
                ),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined,
                  color: AppColors.dashAccent),
              title: const Text(
                'Take a photo',
                style: TextStyle(
                  fontFamily: AppTheme.fontBold,
                  color: AppColors.dashText,
                ),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    setState(() {
      _pickedImagePath = file.path;
      _editing = true;
    });
  }

  Future<void> _loadSecurity() async {
    setState(() => _loadingSecurity = true);
    try {
      final api = ref.read(uniApiProvider);
      final history = await api.getLoginHistory();
      final sessions = await api.getSessions();
      if (!mounted) return;
      setState(() {
        _history = history;
        final list = sessions['sessions'];
        _sessions = list is List
            ? list
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
            : [];
        _loginAlerts = sessions['loginAlertsEnabled'] != false;
        _loadingSecurity = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingSecurity = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final parts = _name.text.trim().split(RegExp(r'\s+'));
      final updated = await ref.read(uniApiProvider).updateProfile(
        {
          'firstName': parts.isNotEmpty ? parts.first : 'User',
          'lastName': parts.length > 1 ? parts.sublist(1).join(' ') : 'User',
          'email': _email.text.trim(),
          'phoneNumber': _phone.text.trim(),
          'department': _dept.text.trim(),
          'studentId': _studentId.text.trim(),
          if (_college != null) 'college': _college,
          if (_year != null) 'year': _year,
        },
        profileImagePath: _pickedImagePath,
      );
      ref.read(authViewModelProvider.notifier).setUser(updated);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _editing = false;
        _pickedImagePath = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.mRed,
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    final current = _currentPassword.text;
    final next = _newPassword.text;
    final confirm = _confirmPassword.text;
    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fill all password fields'),
          backgroundColor: AppColors.mRed,
        ),
      );
      return;
    }
    if (next.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password must be at least 6 characters'),
          backgroundColor: AppColors.mRed,
        ),
      );
      return;
    }
    if (next != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New passwords do not match'),
          backgroundColor: AppColors.mRed,
        ),
      );
      return;
    }

    setState(() => _changingPassword = true);
    try {
      await ref.read(uniApiProvider).changePassword(
            currentPassword: current,
            newPassword: next,
          );
      if (!mounted) return;
      _currentPassword.clear();
      _newPassword.clear();
      _confirmPassword.clear();
      setState(() => _changingPassword = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _changingPassword = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.mRed,
        ),
      );
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _dept.dispose();
    _studentId.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authViewModelProvider).user;
    final colleges = getCollegeOptions(user?.college);
    final photoUrl = ApiEndpoints.resolveMediaUrl(user?.profileImage);

    return SafeArea(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      fontFamily: AppTheme.fontBold,
                      fontSize: 22,
                      color: AppColors.dashText,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (_editing) {
                      _syncFromUser();
                      setState(() => _editing = false);
                    } else {
                      setState(() => _editing = true);
                    }
                  },
                  child: Text(
                    _editing ? 'Cancel' : 'Edit',
                    style: const TextStyle(color: AppColors.dashAccent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.dashAccentSoft,
                    backgroundImage: _pickedImagePath != null
                        ? FileImage(File(_pickedImagePath!))
                        : (photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl) as ImageProvider
                            : null),
                    child: (_pickedImagePath == null && photoUrl.isEmpty)
                        ? Text(
                            '${user?.firstName.isNotEmpty == true ? user!.firstName[0] : 'U'}'
                            '${user?.lastName.isNotEmpty == true ? user!.lastName[0] : ''}',
                            style: const TextStyle(
                              fontFamily: AppTheme.fontBold,
                              fontSize: 28,
                              color: AppColors.dashAccentText,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Material(
                      color: AppColors.dashAccent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _pickPhoto,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                user?.name ?? 'Student',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTheme.fontBold,
                  fontSize: 18,
                  color: AppColors.dashText,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Center(child: SoftChip(label: 'PARTICIPANT')),
            const SizedBox(height: 20),
            DashCard(
              child: Column(
                children: [
                  _field('Full name', _name, enabled: _editing),
                  _field('Email', _email, enabled: _editing),
                  _field('Student ID', _studentId, enabled: _editing),
                  if (_editing) ...[
                    _dropdown(
                      label: 'College',
                      value: colleges.contains(_college) ? _college : null,
                      items: colleges,
                      onChanged: (v) => setState(() => _college = v),
                    ),
                    _dropdown(
                      label: 'Year',
                      value: _years.contains(_year) ? _year : null,
                      items: _years,
                      itemLabel: (y) => 'Year $y',
                      onChanged: (v) => setState(() => _year = v),
                    ),
                  ] else ...[
                    _readonly('College', user?.college ?? '—'),
                    _readonly(
                      'Year',
                      user?.year != null && user!.year!.isNotEmpty
                          ? 'Year ${user.year}'
                          : '—',
                    ),
                  ],
                  _field('Department', _dept, enabled: _editing),
                  _field('Phone', _phone, enabled: _editing),
                  if (_editing)
                    CyanButton(
                      label: 'Save changes',
                      loading: _saving,
                      onPressed: _save,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DashCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Change password',
                    style: TextStyle(
                      fontFamily: AppTheme.fontBold,
                      fontSize: 14,
                      color: AppColors.dashText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Use your current password, then choose a new one.',
                    style: TextStyle(fontSize: 12, color: AppColors.dashMuted),
                  ),
                  const SizedBox(height: 12),
                  _passwordField(
                    'Current password',
                    _currentPassword,
                    obscure: _obscureCurrent,
                    onToggle: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                  _passwordField(
                    'New password',
                    _newPassword,
                    obscure: _obscureNew,
                    onToggle: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  _passwordField(
                    'Confirm new password',
                    _confirmPassword,
                    obscure: _obscureConfirm,
                    onToggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  CyanButton(
                    label: 'Update password',
                    loading: _changingPassword,
                    onPressed: _changePassword,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DashCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Display & sensors',
                    style: TextStyle(
                      fontFamily: AppTheme.fontBold,
                      fontSize: 14,
                      color: AppColors.dashText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Auto brightness uses the ambient light sensor.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.dashMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Builder(
                    builder: (context) {
                      final auto = ref.watch(autoBrightnessProvider);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Auto brightness',
                                style: TextStyle(
                                  color: AppColors.dashText,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                auto.enabled
                                    ? 'Light: ${auto.lux ?? '—'} lux · Brightness ${(auto.brightness * 100).round()}%'
                                    : 'Off — uses system brightness',
                                style: const TextStyle(
                                  color: AppColors.dashMuted,
                                  fontSize: 12,
                                ),
                              ),
                              value: auto.enabled,
                              activeThumbColor: Colors.black,
                              activeTrackColor: AppColors.dashAccent,
                              onChanged: (v) {
                                ref
                                    .read(autoBrightnessProvider.notifier)
                                    .setEnabled(v);
                              },
                            ),
                          ),
                          if (auto.error != null)
                            Text(
                              auto.error!,
                              style: const TextStyle(
                                color: AppColors.mRed,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DashCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Security',
                    style: TextStyle(
                      fontFamily: AppTheme.fontBold,
                      fontSize: 14,
                      color: AppColors.dashText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Material(
                    color: Colors.transparent,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Login alerts',
                        style: TextStyle(
                          color: AppColors.dashText,
                          fontSize: 14,
                        ),
                      ),
                      value: _loginAlerts,
                      activeThumbColor: Colors.black,
                      activeTrackColor: AppColors.dashAccent,
                      onChanged: (v) async {
                        setState(() => _loginAlerts = v);
                        try {
                          await ref
                              .read(uniApiProvider)
                              .updateSecuritySettings(loginAlertsEnabled: v);
                        } catch (_) {}
                      },
                    ),
                  ),
                  if (_loadingSecurity)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: DashLoading(),
                    )
                  else ...[
                    Text(
                      'Active sessions: ${_sessions.length}',
                      style: const TextStyle(
                        color: AppColors.dashMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Recent logins: ${_history.take(3).length}',
                      style: const TextStyle(
                        color: AppColors.dashMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () async {
                        try {
                          await ref.read(uniApiProvider).logoutAll();
                          final email = user?.email;
                          if (email != null) {
                            await ref
                                .read(authViewModelProvider.notifier)
                                .logout(email);
                          }
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (_) => false,
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceFirst('Exception: ', ''),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.mRed,
                        side: const BorderSide(color: AppColors.mRed),
                      ),
                      child: const Text('Logout all devices'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final email = user?.email;
                  if (email == null) return;
                  await ref.read(authViewModelProvider.notifier).logout(email);
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (_) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.mRed,
                  side: const BorderSide(color: AppColors.mRed),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.dashMuted),
        filled: true,
        fillColor: AppColors.surfaceElevatedDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dashBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dashBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dashAccent),
        ),
      );

  Widget _field(
    String label,
    TextEditingController c, {
    required bool enabled,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        enabled: enabled,
        style: const TextStyle(color: AppColors.dashText, fontSize: 14),
        decoration: _inputDeco(label),
      ),
    );
  }

  Widget _passwordField(
    String label,
    TextEditingController c, {
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        obscureText: obscure,
        style: const TextStyle(color: AppColors.dashText, fontSize: 14),
        decoration: _inputDeco(label).copyWith(
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.dashMuted,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String Function(String)? itemLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        key: ValueKey('$label-$value-$_editing'),
        isExpanded: true,
        initialValue: value != null && items.contains(value) ? value : null,
        decoration: _inputDeco(label),
        dropdownColor: AppColors.dashCard,
        iconEnabledColor: AppColors.dashMuted,
        selectedItemBuilder: (context) => items
            .map(
              (c) => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  itemLabel?.call(c) ?? c,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.dashText,
                  ),
                ),
              ),
            )
            .toList(),
        items: items
            .map(
              (c) => DropdownMenuItem(
                value: c,
                child: Text(
                  itemLabel?.call(c) ?? c,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.dashText,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _readonly(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InputDecorator(
        decoration: _inputDeco(label),
        child: Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.dashText, fontSize: 14),
        ),
      ),
    );
  }
}
