// =============================================================
// app_colors.dart
// Color system của PRM393
// Refactor: hạn chế static – dùng object color scheme
// =============================================================

import 'package:flutter/material.dart';

class AppColors {
  final BrandColors brand;
  final BackgroundColors background;
  final TextColors text;
  final BorderColors border;
  final StatusColors status;
  final MiscColors misc;

  const AppColors({
    this.brand = const BrandColors(),
    this.background = const BackgroundColors(),
    this.text = const TextColors(),
    this.border = const BorderColors(),
    this.status = const StatusColors(),
    this.misc = const MiscColors(),
  });

  /// Helper cho order badge
  Color orderStatusBg(String status, {bool dark = false}) {
    return this.status.orderStatusBg(status, dark: dark);
  }

  Color orderStatusText(String status, {bool dark = false}) {
    return this.status.orderStatusText(status, dark: dark);
  }
}

// =============================================================
// BRAND COLORS
// =============================================================

class BrandColors {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;

  const BrandColors({
    this.primary = const Color(0xFF09F6AB),
    this.primaryLight = const Color(0xFF09F6AB),
    this.primaryDark = const Color(0xFF07C98B),
  });
}

// =============================================================
// BACKGROUND
// =============================================================

class BackgroundColors {
  final Color light;
  final Color dark;

  final Color surfaceLight;
  final Color surfaceDark;

  const BackgroundColors({
    this.light = const Color(0xFFF5F8F7),
    this.dark = const Color(0xFF10221C),
    this.surfaceLight = const Color(0xFFFFFFFF),
    this.surfaceDark = const Color(0xFF0F172A),
  });
}

// =============================================================
// TEXT
// =============================================================

class TextColors {
  final Color primaryLight;
  final Color primaryDark;
  final Color secondary;
  final Color hint;
  final Color onPrimary;

  const TextColors({
    this.primaryLight = const Color(0xFF0F172A),
    this.primaryDark = const Color(0xFFF1F5F9),
    this.secondary = const Color(0xFF64748B),
    this.hint = const Color(0xFF94A3B8),
    this.onPrimary = const Color(0xFF0F172A),
  });
}

// =============================================================
// BORDER
// =============================================================

class BorderColors {
  final Color light;
  final Color dark;
  final Color divider;

  const BorderColors({
    this.light = const Color(0xFFE2E8F0),
    this.dark = const Color(0xFF1E293B),
    this.divider = const Color(0xFFE2E8F0),
  });
}

// =============================================================
// STATUS COLORS
// =============================================================

class StatusColors {
  final Color successBg;
  final Color successText;
  final Color successBgDark;
  final Color successTextDark;

  final Color warningBg;
  final Color warningText;
  final Color warningBgDark;
  final Color warningTextDark;

  final Color errorBg;
  final Color errorText;
  final Color errorBgDark;
  final Color errorTextDark;

  final Color infoBg;
  final Color infoText;
  final Color infoBgDark;
  final Color infoTextDark;

  final Color neutralBg;
  final Color neutralText;
  final Color neutralBgDark;
  final Color neutralTextDark;

  const StatusColors({
    this.successBg = const Color(0xFFD1FAE5),
    this.successText = const Color(0xFF065F46),
    this.successBgDark = const Color(0xFF064E3B),
    this.successTextDark = const Color(0xFF34D399),

    this.warningBg = const Color(0xFFFEF3C7),
    this.warningText = const Color(0xFFB45309),
    this.warningBgDark = const Color(0xFF451A03),
    this.warningTextDark = const Color(0xFFFBBF24),

    this.errorBg = const Color(0xFFFEE2E2),
    this.errorText = const Color(0xFFB91C1C),
    this.errorBgDark = const Color(0xFF450A0A),
    this.errorTextDark = const Color(0xFFF87171),

    this.infoBg = const Color(0xFFDBEAFE),
    this.infoText = const Color(0xFF1D4ED8),
    this.infoBgDark = const Color(0xFF1E3A5F),
    this.infoTextDark = const Color(0xFF60A5FA),

    this.neutralBg = const Color(0xFFF1F5F9),
    this.neutralText = const Color(0xFF475569),
    this.neutralBgDark = const Color(0xFF1E293B),
    this.neutralTextDark = const Color(0xFF94A3B8),
  });

  Color orderStatusBg(String status, {bool dark = false}) {
    switch (status.toUpperCase()) {
      case 'BOOKED':
      case 'CREATED':
        return dark ? warningBgDark : warningBg;

      case 'IN_PROGRESS':
      case 'PAID':
      case 'SHIPPING':
        return dark ? successBgDark : successBg;

      case 'COMPLETED':
        return dark ? neutralBgDark : neutralBg;

      case 'CANCELLED':
        return dark ? errorBgDark : errorBg;

      default:
        return dark ? neutralBgDark : neutralBg;
    }
  }

  Color orderStatusText(String status, {bool dark = false}) {
    switch (status.toUpperCase()) {
      case 'BOOKED':
      case 'CREATED':
        return dark ? warningTextDark : warningText;

      case 'IN_PROGRESS':
      case 'PAID':
      case 'SHIPPING':
        return dark ? successTextDark : successText;

      case 'COMPLETED':
        return dark ? neutralTextDark : neutralText;

      case 'CANCELLED':
        return dark ? errorTextDark : errorText;

      default:
        return dark ? neutralTextDark : neutralText;
    }
  }
}

// =============================================================
// MISC
// =============================================================

class MiscColors {
  final Color hoverLight;
  final Color hoverDark;
  final Color shadow;
  final Color overlay;

  const MiscColors({
    this.hoverLight = const Color(0xFFF1F5F9),
    this.hoverDark = const Color(0xFF1E293B),
    this.shadow = const Color(0x1A000000),
    this.overlay = const Color(0x80000000),
  });
}
