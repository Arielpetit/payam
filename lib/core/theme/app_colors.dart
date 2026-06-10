import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─────────────────────────────────────────────────────────────
  // PRIMARY COLORS - Only 3 colors: Black, White, Teal
  // ─────────────────────────────────────────────────────────────
  
  /// Primary teal - used for buttons, accents, highlights
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryDark = Color(0xFF0D9488);
  static const Color primaryLight = Color(0xFF14B8A6);
  
  /// Black - for text and dark mode
  static const Color black = Color(0xFF000000);
  
  /// White - for backgrounds and light mode  
  static const Color white = Color(0xFFFFFFFF);
  
  // Common aliases
  static const Color background = white;
  static const Color surface = white;
  static const Color surfaceSecondary = Color(0xFFF9FAFB);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  
  // Text colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textHint = Color(0xFF9CA3AF);
  
  // Semantic colors
  static const Color success = Color(0xFF22C55E);
  static const Color successSurface = Color(0xFFDCFCE7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSurface = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoSurface = Color(0xFFEFF6FF);
  
  // Borders
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);
  
  // ─────────────────────────────────────────────────────────────
  // DARK MODE COLORS
  // ─────────────────────────────────────────────────────────────
  
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF0A0A0A);
  static const Color darkSurfaceSecondary = Color(0xFF141414);
  static const Color darkSurfaceVariant = Color(0xFF1A1A1A);
  static const Color darkDivider = Color(0xFF262626);
  static const Color darkBorder = Color(0xFF262626);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkTextHint = Color(0xFF666666);
  
  // ─────────────────────────────────────────────────────────────
  // GLASS EFFECT COLORS
  // ─────────────────────────────────────────────────────────────
  
  static Color get glassLight => white.withOpacity(0.72);
  static Color get glassDark => black.withOpacity(0.48);
  static Color get glassBorderLight => white.withOpacity(0.2);
  static Color get glassBorderDark => white.withOpacity(0.08);
  
  // Primary Surface (for chips, etc.)
  static Color get primarySurface => primary.withOpacity(0.1);
  
  // ─────────────────────────────────────────────────────────────
  // GRADIENTS
  // ─────────────────────────────────────────────────────────────
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
  );
  
  // ─────────────────────────────────────────────────────────────
  // SHADOWS - Minimal, Apple-style
  // ─────────────────────────────────────────────────────────────
  
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: black.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: black.withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get primaryShadow => [
    BoxShadow(
      color: primary.withOpacity(0.24),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Legacy aliases for backward compatibility
  static const Color secondary = Color(0xFF0F172A);
  static const Color secondaryLight = Color(0xFF1E293B);
  
  // Shadow helpers
  static List<BoxShadow> get cardShadow => shadowMd;
  static List<BoxShadow> get elevatedShadow => shadowLg;
  static List<BoxShadow> get darkCardShadow => [
    BoxShadow(
      color: black.withOpacity(0.5),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Helper for creating shadows from any color
  static List<BoxShadow> shadowFromColor(Color color, {double opacity = 0.1, double blur = 16, double offset = 4}) {
    return [BoxShadow(color: color.withOpacity(opacity), blurRadius: blur, offset: Offset(0, offset))];
  }
}