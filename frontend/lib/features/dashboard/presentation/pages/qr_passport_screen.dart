import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import 'package:uni_sphere/core/api/uni_api_service.dart';
import 'package:uni_sphere/core/models/event_models.dart';
import 'package:uni_sphere/core/services/auto_brightness_provider.dart';
import 'package:uni_sphere/core/widgets/dash_widgets.dart';
import 'package:uni_sphere/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:uni_sphere/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:uni_sphere/themes/app_colors.dart';
import 'package:uni_sphere/themes/app_theme.dart';

class QrPassportScreen extends ConsumerStatefulWidget {
  const QrPassportScreen({super.key});

  @override
  ConsumerState<QrPassportScreen> createState() => _QrPassportScreenState();
}

class _QrPassportScreenState extends ConsumerState<QrPassportScreen> {
  final _auth = LocalAuthentication();
  bool _loading = true;
  bool _unlocked = false;
  bool _unlocking = false;
  String? _authError;
  List<RegistrationModel> _passes = [];
  RegistrationModel? _active;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final regs = await ref.read(uniApiProvider).getMyRegistrations();
      final active = regs.where((r) => r.status != 'cancelled').toList();
      if (!mounted) return;
      setState(() {
        _passes = active;
        _active = active.isNotEmpty ? active.first : null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _passes = [];
        _active = null;
        _loading = false;
      });
    }
  }

  Future<void> _unlock() async {
    setState(() {
      _unlocking = true;
      _authError = null;
    });
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) {
        if (!mounted) return;
        setState(() {
          _unlocking = false;
          _authError =
              'This device has no screen lock. Set a PIN or fingerprint in phone Settings → Security, then try again.';
        });
        return;
      }

      // Fingerprint when enrolled; otherwise device PIN/pattern.
      final ok = await _auth.authenticate(
        localizedReason:
            'Unlock QR Passport with fingerprint or your device lock',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );

      if (!mounted) return;
      setState(() {
        _unlocked = ok;
        _unlocking = false;
        if (!ok) {
          _authError =
              'Authentication failed. Try again with fingerprint or your device PIN.';
        }
      });
      if (ok) {
        // Brighter screen helps door scanners read the QR.
        unawaited(ref.read(autoBrightnessProvider.notifier).boostForQr());
      }
    } on LocalAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _unlocking = false;
        _authError = (e.description ?? '').trim().isNotEmpty
            ? e.description
            : 'Could not authenticate.';
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _unlocking = false;
        _authError = e.message ?? 'Could not authenticate.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _unlocking = false;
        _authError = 'Could not authenticate.';
      });
    }
  }

  void _lock() {
    setState(() {
      _unlocked = false;
      _authError = null;
    });
  }

  Widget _lockGate() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const Text(
          'QR Passport',
          style: TextStyle(
            fontFamily: AppTheme.fontBold,
            fontSize: 22,
            color: AppColors.dashText,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Biometric unlock required to view your QR pass',
          style: TextStyle(fontSize: 13, color: AppColors.dashMuted),
        ),
        const SizedBox(height: 48),
        DashCard(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.dashAccentSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.fingerprint_rounded,
                  size: 40,
                  color: AppColors.dashAccentText,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Passport locked',
                style: TextStyle(
                  fontFamily: AppTheme.fontBold,
                  fontSize: 17,
                  color: AppColors.dashText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Tap Unlock below\n'
                '2. Use your fingerprint (or device PIN if asked)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.dashMuted,
                  height: 1.45,
                ),
              ),
              if (_authError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _authError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mRed,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  onPressed: _unlocking ? null : _unlock,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.dashAccent,
                    foregroundColor: Colors.black,
                  ),
                  icon: _unlocking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(Icons.fingerprint_rounded),
                  label: Text(
                    _unlocking ? 'Waiting…' : 'Unlock with biometrics',
                    style: const TextStyle(fontFamily: AppTheme.fontBold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authViewModelProvider).user;
    final userId = user?.id ?? user?.email ?? 'user';

    // Re-lock when leaving the Passport tab.
    ref.listen<int>(studentNavIndexProvider, (prev, next) {
      if (next != 3 && _unlocked) _lock();
    });

    return SafeArea(
      child: _loading
          ? const DashLoading()
          : !_unlocked
              ? _lockGate()
              : RefreshIndicator(
                  color: AppColors.dashAccent,
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'QR Passport',
                              style: TextStyle(
                                fontFamily: AppTheme.fontBold,
                                fontSize: 22,
                                color: AppColors.dashText,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _lock,
                            icon: const Icon(
                              Icons.lock_outline_rounded,
                              size: 18,
                              color: AppColors.dashMuted,
                            ),
                            label: const Text(
                              'Lock',
                              style: TextStyle(
                                color: AppColors.dashMuted,
                                fontFamily: AppTheme.fontBold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Your digital event passes',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.dashMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_passes.isEmpty)
                        const EmptyState(
                          icon: Icons.qr_code_2_rounded,
                          title: 'No passes yet',
                          subtitle:
                              'Register for an event to get your QR pass.',
                        )
                      else ...[
                        if (_active != null)
                          DashCard(
                            child: Column(
                              children: [
                                Text(
                                  _active!.eventTitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontBold,
                                    fontSize: 16,
                                    color: AppColors.dashText,
                                  ),
                                ),
                                if ((_active!.event?.cashPrize ?? '')
                                    .trim()
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'Prize: ${_active!.event!.cashPrize}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.dashAccentText,
                                      fontFamily: AppTheme.fontBold,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  'Pass: ${_active!.passCode}',
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontBold,
                                    fontSize: 12,
                                    color: AppColors.dashAccentText,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: QrImageView(
                                    data: _active!.qrValue(userId),
                                    size: 180,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '${_active!.event?.location ?? ''} · ${_active!.event?.formattedDate ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.dashMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        const Text(
                          'All passes',
                          style: TextStyle(
                            fontFamily: AppTheme.fontBold,
                            fontSize: 14,
                            color: AppColors.dashText,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._passes.map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: DashCard(
                              onTap: () => setState(() => _active = p),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.qr_code_2,
                                    color: AppColors.dashAccent,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.eventTitle,
                                          style: const TextStyle(
                                            fontFamily: AppTheme.fontBold,
                                            fontSize: 14,
                                            color: AppColors.dashText,
                                          ),
                                        ),
                                        Text(
                                          [
                                            if ((p.event?.formattedDate ?? '')
                                                .isNotEmpty)
                                              p.event!.formattedDate,
                                            p.passCode,
                                          ].join(' · '),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.dashAccentText,
                                            fontFamily: AppTheme.fontBold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_active?.id == p.id)
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.dashAccent,
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}
