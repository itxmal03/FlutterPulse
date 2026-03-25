import 'dart:ui';

class AppColors {
  static bool isDark = true;
  static Color get bg => isDark ? const Color(0xFF0D0F14) : const Color(0xFFFFFFFF);
  static Color get sidebar => isDark ? const Color(0xFF111318) : const Color(0xFFF5F5F5);
  static Color get surface => isDark ? const Color(0xFF161A23) : const Color(0xFFEFEFEF);
  static Color get surfaceElevated => isDark ? const Color(0xFF1C2130) : const Color(0xFFF0F0F0);
  static Color get border => isDark ? const Color(0xFF252B3B) : const Color(0xFFD0D0D0);
  static Color get accent => const Color(0xFF4D9EFF);
  
  static Color get accentGlow => const Color(0x334D9EFF);
  static Color get accentSecondary => const Color(0xFF7C6EFF);
  static Color get textPrimary => isDark ? const Color(0xFFE2E8F4) : const Color(0xFF000000);
  static Color get textSecondary => isDark ? const Color(0xFF6B7A99) : const Color(0xFF555555);
  static Color get textMuted => isDark ? const Color(0xFF3D4A61) : const Color(0xFF888888);
  static Color get success => isDark ? const Color(0xFF2ECC71) : const Color(0xFF28A745);
  static Color get error => isDark ? const Color(0xFFFF4E4E) : const Color(0xFFDC3545);
  static Color get warning => isDark ? const Color(0xFFFFB347) : const Color(0xFFFFC107);
  static Color get info => isDark ? const Color(0xFFB0BED4) : const Color(0xFF17A2B8);
  static Color get stepActive => isDark ? const Color(0xFF4D9EFF) : const Color(0xFF4D9EFF);
  static Color get stepDone => isDark ? const Color(0xFF2ECC71) : const Color(0xFF28A745);
  static Color get stepPending => isDark ? const Color(0xFF252B3B) : const Color(0xFFEFEFEF);
  static Color get stopBtn => isDark ? const Color(0xFFFF4E4E) : const Color(0xFFDC3545);
  static Color get stopBtnBg => isDark ? const Color(0x22FF4E4E) : const Color(0x22DC3545);
}