import 'package:flutter/material.dart';

/// Exact CSS tokens from UniSphere website `globals.css`.
/// Do not approximate — use these hex values only.
class AppColors {
  AppColors._();

  // ── Marketing / Auth / Landing (LIGHT) ───────────────────────────────────
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFF8FBFF);
  static const Color surfaceElevated = Color(0xFFEEF2F7);
  static const Color hairline = Color(0xFFE2E8F0);
  static const Color onDark = Color(0xFF0F172A);
  static const Color body = Color(0xFF334155);
  static const Color bodyStrong = Color(0xFF1E293B);
  static const Color muted = Color(0xFF64748B);
  static const Color mRed = Color(0xFFEF4444);
  static const Color mBlueLight = Color(0xFF60A5FA);
  static const Color mBlueDark = Color(0xFF2563EB);
  static const Color carbon = Color(0xFFCBD5E1);

  // ── Logged-in dashboards (DARK + CYAN) ───────────────────────────────────
  static const Color dashBg = Color(0xFF0A0A0A);
  static const Color dashHeader = Color(0xFF0A0A0A);
  static const Color dashSidebar = Color(0xFF000000);
  static const Color dashSidebarHover = Color(0xFF1A1A1A);
  static const Color dashCard = Color(0xFF141414);
  static const Color dashBorder = Color(0xFF2A2A2A);
  static const Color dashText = Color(0xFFFFFFFF);
  static const Color dashMuted = Color(0xFF94A3B8);
  static const Color dashAccent = Color(0xFF00C2E0);
  static const Color dashAccentHover = Color(0xFF22D3EE);
  static const Color dashAccentSoft = Color(0xFF0A2F36);
  static const Color dashAccentText = Color(0xFF67E8F9);
  static const Color dashFun = Color(0xFF06B6D4);
  static const Color surfaceElevatedDark = Color(0xFF1A1A1A);
  static const Color dashBgEnd = Color(0xFF121212);

  // Stat card icon accents (match website)
  static const Color statPurple = Color(0xFFC084FC);
  static const Color statGreen = Color(0xFF34D399);
  static const Color statOrange = Color(0xFFFB923C);
  static const Color amber = Color(0xFFF59E0B);
}
