// =============================================================================
// CARBO DESIGN SYSTEM
// Version : 1.0.0
// App     : Carbo — Car Rental Platform
// Updated : 2026
//
// Sections
//   CarboColors      — Color tokens  (light, dark, semantic)
//   CarboRadius      — Border radius scale + BorderRadius helpers
//   CarboSpacing     — 8-pt spacing scale + EdgeInsets helpers
//   CarboShadow      — BoxShadow presets
//   CarboTypography  — TextStyle presets  (runtime getters — .sp requires init)
//   CarboDuration    — Animation durations
//   CarboGradients   — LinearGradient presets
//   CarboIcons       — IconData constants
//
// Usage
//   Color   → CarboColors.primary
//   Radius  → CarboRadius.md          (12.0)
//   Space   → CarboSpacing.x4         (16.0)
//   Text    → CarboTypography.bodyMedium
//   Shadow  → decoration: BoxDecoration(boxShadow: CarboShadow.card)
//   Icons   → Icon(CarboIcons.wallet)
//
// Notes
//   • CarboTypography getters are NOT const — .sp resolves at runtime after
//     ScreenUtil.init(). Call them inside build() only.
//   • Register the 'Inter' font family in pubspec.yaml to activate the
//     typeface; without it Flutter falls back to the system default.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────────────────────────────────────

class CarboColors {
  CarboColors._();

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFFE93A3A);
  static const Color primaryDark  = Color(0xFFB72E2E);
  static const Color primaryLight = Color(0xFFFFECEC);

  // ── Backgrounds & surfaces (light) ─────────────────────────────────────────
  static const Color background = Color(0xFFF7F8F8);
  static const Color surface    = Color(0xFFFFFFFF);

  // ── Backgrounds & surfaces (dark) ──────────────────────────────────────────
  static const Color darkBackground = Color(0xFF171717);
  static const Color darkSurface    = Color(0xFF1D1D1D);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1D1D1D);
  static const Color textSecondary = Color(0xFF8F9396);
  static const Color textDisabled  = Color(0xFFBCBCBC);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark    = Color(0xFFFFFFFF);

  // ── Semantic — success ─────────────────────────────────────────────────────
  static const Color success   = Color(0xFF21C77B);
  static const Color successBg = Color(0xFFEBFAF3);

  // ── Semantic — warning ─────────────────────────────────────────────────────
  static const Color warning   = Color(0xFFFFB86B);
  static const Color warningBg = Color(0xFFFFF4E5);

  // ── Semantic — error ───────────────────────────────────────────────────────
  static const Color error   = Color(0xFFE93A3A);
  static const Color errorBg = Color(0xFFFFECEC);

  // ── Semantic — info ────────────────────────────────────────────────────────
  static const Color info   = Color(0xFF4A90D9);
  static const Color infoBg = Color(0xFFECF4FD);

  // ── Financial semantic ─────────────────────────────────────────────────────
  static const Color credit   = Color(0xFF21C77B); // money in
  static const Color debit    = Color(0xFFE93A3A); // money out
  static const Color creditBg = Color(0xFFEBFAF3);
  static const Color debitBg  = Color(0xFFFFECEC);

  // ── Dividers & borders ─────────────────────────────────────────────────────
  static const Color divider     = Color(0xFFEEEEEE);
  static const Color border      = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF2F2F2);

  // ── Shimmer ────────────────────────────────────────────────────────────────
  static const Color shimmerBase      = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // ── Gold / premium ─────────────────────────────────────────────────────────
  static const Color gold      = Color(0xFFFFB300);
  static const Color goldLight = Color(0xFFFFF8E1);
}

// ─────────────────────────────────────────────────────────────────────────────
// RADIUS
// ─────────────────────────────────────────────────────────────────────────────

class CarboRadius {
  CarboRadius._();

  // ── Raw double values ──────────────────────────────────────────────────────
  static const double xs   =   4.0;
  static const double sm   =   8.0;
  static const double md   =  12.0;
  static const double lg   =  16.0;
  static const double xl   =  20.0;
  static const double xxl  =  32.0;
  static const double full = 999.0;

  // ── BorderRadius helpers ───────────────────────────────────────────────────
  static const BorderRadius xsAll   = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll   = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll   = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll   = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll   = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlAll  = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));

  // ── Top-only helpers (bottom sheet, card tops) ─────────────────────────────
  static const BorderRadius mdTop = BorderRadius.only(
    topLeft:  Radius.circular(md),
    topRight: Radius.circular(md),
  );
  static const BorderRadius lgTop = BorderRadius.only(
    topLeft:  Radius.circular(lg),
    topRight: Radius.circular(lg),
  );
  static const BorderRadius xlTop = BorderRadius.only(
    topLeft:  Radius.circular(xl),
    topRight: Radius.circular(xl),
  );
  static const BorderRadius xxlTop = BorderRadius.only(
    topLeft:  Radius.circular(xxl),
    topRight: Radius.circular(xxl),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SPACING
// ─────────────────────────────────────────────────────────────────────────────

class CarboSpacing {
  CarboSpacing._();

  // ── Scale (8-pt grid) ──────────────────────────────────────────────────────
  static const double x1  =  4.0;
  static const double x2  =  8.0;
  static const double x3  = 12.0;
  static const double x4  = 16.0;
  static const double x5  = 20.0;
  static const double x6  = 24.0;
  static const double x8  = 32.0;
  static const double x10 = 40.0;
  static const double x12 = 48.0;

  // ── Named aliases ──────────────────────────────────────────────────────────
  static const double micro   = x1;
  static const double small   = x2;
  static const double medium  = x4;
  static const double large   = x6;
  static const double xLarge  = x8;
  static const double xxLarge = x12;

  // ── EdgeInsets helpers ─────────────────────────────────────────────────────
  static const EdgeInsets pagePadding    = EdgeInsets.symmetric(horizontal: x4);
  static const EdgeInsets pageAllPadding = EdgeInsets.symmetric(horizontal: x4, vertical: x4);
  static const EdgeInsets cardPadding    = EdgeInsets.all(x4);
  static const EdgeInsets cardPaddingMd  = EdgeInsets.all(x3);
  static const EdgeInsets sectionGap     = EdgeInsets.symmetric(vertical: x5);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: x4,
    vertical: x3,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SHADOWS
// ─────────────────────────────────────────────────────────────────────────────

class CarboShadow {
  CarboShadow._();

  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> strong = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 12,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x29000000),
      blurRadius: 32,
      spreadRadius: 0,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: Color(0x33E93A3A),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> goldGlow = [
    BoxShadow(
      color: Color(0x33FFB300),
      blurRadius: 20,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// TYPOGRAPHY
//
// All getters are intentionally non-const because .sp reads ScreenUtil at
// runtime. Call inside build() / Obx() only — never at class/field init time.
// ─────────────────────────────────────────────────────────────────────────────

class CarboTypography {
  CarboTypography._();

  static const String _font = 'Inter';

  // ── Display ────────────────────────────────────────────────────────────────

  static TextStyle get displayLarge => TextStyle(
    fontSize: 32.0.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
    color: CarboColors.textPrimary,
    fontFamily: _font,
  );

  static TextStyle get displayMedium => TextStyle(
    fontSize: 28.0.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
    color: CarboColors.textPrimary,
    fontFamily: _font,
  );

  // ── Headline ───────────────────────────────────────────────────────────────

  static TextStyle get headlineLarge => TextStyle(
    fontSize: 24.0.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.3,
    color: CarboColors.textPrimary,
    fontFamily: _font,
  );

  static TextStyle get headlineMedium => TextStyle(
    fontSize: 20.0.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    color: CarboColors.textPrimary,
    fontFamily: _font,
  );

  static TextStyle get headlineSmall => TextStyle(
    fontSize: 18.0.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    color: CarboColors.textPrimary,
    fontFamily: _font,
  );

  // ── Title ──────────────────────────────────────────────────────────────────

  static TextStyle get titleLarge => TextStyle(
    fontSize: 16.0.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: CarboColors.textPrimary,
    fontFamily: _font,
  );

  static TextStyle get titleMedium => TextStyle(
    fontSize: 15.0.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
    color: CarboColors.textPrimary,
    fontFamily: _font,
  );

  static TextStyle get titleSmall => TextStyle(
    fontSize: 14.0.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
    color: CarboColors.textPrimary,
    fontFamily: _font,
  );

  // ── Body ───────────────────────────────────────────────────────────────────

  static TextStyle get bodyLarge => TextStyle(
    fontSize: 16.0.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
    color: CarboColors.textPrimary,
    fontFamily: _font,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontSize: 14.0.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
    color: CarboColors.textPrimary,
    fontFamily: _font,
  );

  static TextStyle get bodySmall => TextStyle(
    fontSize: 12.0.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
    color: CarboColors.textSecondary,
    fontFamily: _font,
  );

  // ── Label ──────────────────────────────────────────────────────────────────

  static TextStyle get labelLarge => TextStyle(
    fontSize: 14.0.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
    color: CarboColors.textPrimary,
    fontFamily: _font,
  );

  static TextStyle get labelMedium => TextStyle(
    fontSize: 12.0.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
    color: CarboColors.textSecondary,
    fontFamily: _font,
  );

  static TextStyle get labelSmall => TextStyle(
    fontSize: 10.0.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
    color: CarboColors.textSecondary,
    fontFamily: _font,
  );

  // ── Convenience — on-primary (white text) ──────────────────────────────────

  static TextStyle get buttonLabel => TextStyle(
    fontSize: 15.0.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.0,
    color: CarboColors.textOnPrimary,
    fontFamily: _font,
  );

  static TextStyle get caption => TextStyle(
    fontSize: 11.0.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    height: 1.4,
    color: CarboColors.textSecondary,
    fontFamily: _font,
  );

  static TextStyle get overline => TextStyle(
    fontSize: 10.0.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    height: 1.4,
    color: CarboColors.textSecondary,
    fontFamily: _font,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DURATIONS
// ─────────────────────────────────────────────────────────────────────────────

class CarboDuration {
  CarboDuration._();

  static const Duration fast   = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow   = Duration(milliseconds: 350);
  static const Duration xSlow  = Duration(milliseconds: 500);
}

// ─────────────────────────────────────────────────────────────────────────────
// GRADIENTS
// ─────────────────────────────────────────────────────────────────────────────

class CarboGradients {
  CarboGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFE93A3A),
      Color(0xFFB72E2E),
    ],
  );

  static const LinearGradient primaryVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE93A3A),
      Color(0xFFB72E2E),
    ],
  );

  static const LinearGradient dark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1D1D1D),
      Color(0xFF171717),
    ],
  );

  static const LinearGradient fadeDown = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00F7F8F8),
      Color(0xFFF7F8F8),
    ],
  );

  static const LinearGradient coinGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD54F),
      Color(0xFFFFB300),
      Color(0xFFFF8F00),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient surfaceFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00FFFFFF),
      Color(0xFFFFFFFF),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ICONS
// ─────────────────────────────────────────────────────────────────────────────

class CarboIcons {
  CarboIcons._();

  // ── Financial ──────────────────────────────────────────────────────────────
  static const IconData wallet      = Icons.account_balance_wallet_outlined;
  static const IconData topUp       = Icons.add_circle_outline;
  static const IconData transaction = Icons.receipt_long_outlined;
  static const IconData credit      = Icons.arrow_circle_down_outlined;
  static const IconData debit       = Icons.arrow_circle_up_outlined;
  static const IconData refund      = Icons.currency_exchange;
  static const IconData payment     = Icons.credit_card_outlined;

  // ── Car rental ─────────────────────────────────────────────────────────────
  static const IconData car     = Icons.directions_car_outlined;
  static const IconData booking = Icons.calendar_month_outlined;

  // ── User ───────────────────────────────────────────────────────────────────
  static const IconData profile = Icons.person_outline;

  // ── Navigation ─────────────────────────────────────────────────────────────
  static const IconData back    = Icons.arrow_back_ios_new;
  static const IconData refresh = Icons.refresh_rounded;
  static const IconData close   = Icons.close_rounded;

  // ── Status / feedback ──────────────────────────────────────────────────────
  static const IconData success = Icons.check_circle_outline;
  static const IconData warning = Icons.warning_amber_outlined;
  static const IconData error   = Icons.error_outline;
  static const IconData info    = Icons.info_outline;
  static const IconData noData  = Icons.inbox_outlined;
}
