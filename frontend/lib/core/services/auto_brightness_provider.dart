import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light/light.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'auto_brightness_enabled';

class AutoBrightnessState {
  final bool enabled;
  final int? lux;
  final double brightness;
  final String? error;

  const AutoBrightnessState({
    this.enabled = false,
    this.lux,
    this.brightness = 0.5,
    this.error,
  });

  AutoBrightnessState copyWith({
    bool? enabled,
    int? lux,
    double? brightness,
    String? error,
    bool clearError = false,
  }) {
    return AutoBrightnessState(
      enabled: enabled ?? this.enabled,
      lux: lux ?? this.lux,
      brightness: brightness ?? this.brightness,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final autoBrightnessProvider =
    StateNotifierProvider<AutoBrightnessNotifier, AutoBrightnessState>((ref) {
  final notifier = AutoBrightnessNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});

class AutoBrightnessNotifier extends StateNotifier<AutoBrightnessState> {
  AutoBrightnessNotifier() : super(const AutoBrightnessState()) {
    _restore();
  }

  final _light = Light();
  StreamSubscription<int>? _sub;
  double? _lastApplied;
  DateTime _lastApplyAt = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_prefsKey) ?? false;
    if (enabled) {
      await setEnabled(true);
    }
  }

  /// Maps ambient lux → app screen brightness (0.15–1.0).
  static double brightnessFromLux(int lux) {
    if (lux < 0) return 0.5;
    // log curve: dark rooms dimmer, bright rooms brighter
    final t = math.log(lux + 1) / math.log(10000);
    return t.clamp(0.15, 1.0);
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, enabled);

    if (!enabled) {
      await _stop();
      state = state.copyWith(enabled: false, clearError: true);
      return;
    }

    state = state.copyWith(enabled: true, clearError: true);
    await _start();
  }

  Future<void> _start() async {
    await _sub?.cancel();
    _sub = null;

    try {
      _sub = _light.lightSensorStream.listen(
        (lux) {
          if (!state.enabled) return;
          if (lux < 0) {
            state = state.copyWith(
              error: 'Light sensor unavailable on this device.',
            );
            return;
          }
          final next = brightnessFromLux(lux);
          state = state.copyWith(lux: lux, brightness: next, clearError: true);
          _applyBrightness(next);
        },
        onError: (Object e) {
          state = state.copyWith(
            error: 'Light sensor error. Try a physical device or emulator Virtual sensors.',
          );
          if (kDebugMode) {
            debugPrint('Light sensor error: $e');
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        enabled: false,
        error: 'Could not start light sensor.',
      );
    }
  }

  Future<void> _applyBrightness(double value) async {
    final now = DateTime.now();
    if (_lastApplied != null &&
        (value - _lastApplied!).abs() < 0.04 &&
        now.difference(_lastApplyAt).inMilliseconds < 400) {
      return;
    }
    _lastApplied = value;
    _lastApplyAt = now;
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(value);
    } catch (e) {
      if (kDebugMode) debugPrint('set brightness failed: $e');
    }
  }

  Future<void> _stop() async {
    await _sub?.cancel();
    _sub = null;
    _lastApplied = null;
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } catch (_) {}
  }

  /// Temporary boost (e.g. when showing a QR code).
  Future<void> boostForQr() async {
    try {
      final target = math.max(state.brightness, 0.85);
      await ScreenBrightness.instance.setApplicationScreenBrightness(target);
    } catch (_) {}
  }

  @override
  void dispose() {
    unawaited(_stop());
    super.dispose();
  }
}