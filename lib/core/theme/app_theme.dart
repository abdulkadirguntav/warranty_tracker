import 'package:flutter/material.dart';

import '../utils/warranty_calculator.dart';

/// Centralized Material 3 theme — premium "Warranty Wallet" fintech aesthetic.
///
/// Color philosophy (Dribbble/Mobbin inspired, 2025):
/// * Primary: Blue #3B82F6 — trust, authority, fintech
/// * Secondary: Teal #14B8A6 — accent, gradient partner
/// * Green is RESERVED for "Active" status only
/// * 60-30-10 rule: neutral BG (60%), brand blue (30%), accent (10%)
class AppTheme {
  AppTheme._();

  // ── Brand colors ─────────────────────────────────────────────────────
  static const Color brandBlue   = Color(0xFF3B82F6);
  static const Color brandTeal   = Color(0xFF14B8A6);
  static const Color brandBlueDeep = Color(0xFF2563EB);

  // ── Surfaces ────────────────────────────────────────────────────────
  static const Color _scaffoldLight   = Color(0xFFF8FAFC);
  static const Color _cardLight       = Color(0xFFFFFFFF);
  static const Color _scaffoldDark    = Color(0xFF0F172A);
  static const Color _cardDark        = Color(0xFF1E293B);
  static const Color _borderLight     = Color(0xFFE2E8F0);
  static const Color _borderDark      = Color(0xFF334155);
  static const Color _textSubtleLight = Color(0xFF6B7280);
  static const Color _textSubtleDark  = Color(0xFF94A3B8);

  // ── Status colors ────────────────────────────────────────────────────
  /// Active warranty — green (distinct from brand blue).
  static const Color active       = Color(0xFF22C55E);
  /// Expiring soon — amber.
  static const Color expiringSoon = Color(0xFFF59E0B);
  /// Expired — red.
  static const Color expired      = Color(0xFFEF4444);

  static Color levelSoftColor(WarrantyLevel level) => switch (level) {
    WarrantyLevel.active       => active.withValues(alpha: 0.12),
    WarrantyLevel.expiringSoon => expiringSoon.withValues(alpha: 0.12),
    WarrantyLevel.expired      => expired.withValues(alpha: 0.12),
  };

  static Color levelColor(WarrantyLevel level) => switch (level) {
    WarrantyLevel.active       => active,
    WarrantyLevel.expiringSoon => expiringSoon,
    WarrantyLevel.expired      => expired,
  };

  // ── Corner radii ────────────────────────────────────────────────────
  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 24;

  // ── Shadows ─────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.03),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get cardShadowDark => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.3),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ── Gradient ─────────────────────────────────────────────────────────
  static const LinearGradient summaryCardGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Public theme getters ─────────────────────────────────────────────
  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark  => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandBlue,
      brightness: brightness,
      primary: brandBlue,
      onPrimary: Colors.white,
      primaryContainer:
          isDark ? const Color(0xFF1E3A5F) : const Color(0xFFDBEAFE),
      onPrimaryContainer:
          isDark ? const Color(0xFFBFD7FE) : brandBlueDeep,
      secondary: brandTeal,
      onSecondary: Colors.white,
      surface: isDark ? _scaffoldDark : _scaffoldLight,
      onSurface:
          isDark ? const Color(0xFFE2E8F0) : const Color(0xFF111827),
      surfaceContainerLowest:
          isDark ? const Color(0xFF0A1120) : const Color(0xFFF8FAFC),
      surfaceContainerLow:
          isDark ? const Color(0xFF131C2E) : const Color(0xFFF1F5F9),
      surfaceContainer: isDark ? _cardDark : _cardLight,
      outlineVariant: isDark ? _borderDark : _borderLight,
    );

    final cardColor   = isDark ? _cardDark   : _cardLight;
    final borderColor = isDark ? _borderDark : _borderLight;
    final subtle      = isDark ? _textSubtleDark : _textSubtleLight;
    final textColor   = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF111827);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? _scaffoldDark : _scaffoldLight,

      // ── AppBar ────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: isDark ? _scaffoldDark : _scaffoldLight,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface, size: 22),
      ),

      // ── Cards (no border — shadow only) ───────────────────────────
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Divider ───────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),

      // ── Text ──────────────────────────────────────────────────────
      textTheme: _buildTextTheme(colorScheme, subtle, textColor),

      // ── Input fields ──────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF1F5F9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        labelStyle: TextStyle(color: subtle, fontSize: 14),
        hintStyle: TextStyle(color: subtle.withValues(alpha: 0.7), fontSize: 14),
        suffixIconColor: subtle,
        prefixIconColor: subtle,
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.primary,
        selectionColor: colorScheme.primary.withValues(alpha: 0.25),
        selectionHandleColor: colorScheme.primary,
      ),

      // ── Buttons ───────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.1,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          side: BorderSide(color: borderColor, width: 1.5),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),

      // ── FAB ───────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: brandBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // ── Chips ─────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(color: borderColor),
        selectedColor: colorScheme.primaryContainer,
        backgroundColor: cardColor,
        labelStyle: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        secondaryLabelStyle: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
        checkmarkColor: colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── Progress ──────────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        linearTrackColor: colorScheme.surfaceContainerLow,
        linearMinHeight: 6,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: colorScheme.primary,
      ),

      // ── SnackBar ─────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        backgroundColor:
            isDark ? const Color(0xFF1E293B) : const Color(0xFF1E293B),
        contentTextStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),

      // ── TabBar ────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: subtle,
        indicatorColor: colorScheme.primary,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
      ),

      // ── Icons ─────────────────────────────────────────────────────
      iconTheme: IconThemeData(color: colorScheme.onSurface, size: 22),

      // ── DropdownMenu ─────────────────────────────────────────────
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: textColor, fontSize: 14),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(cardColor),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
              side: BorderSide(color: borderColor),
            ),
          ),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(
      ColorScheme scheme, Color subtle, Color text) {
    const base = Typography.englishLike2021;
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: text,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: text,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: text,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: text,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: text,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: text, fontSize: 15),
      bodyMedium: base.bodyMedium?.copyWith(color: text),
      bodySmall: base.bodySmall?.copyWith(color: subtle),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: text,
      ),
      labelMedium: base.labelMedium?.copyWith(
        color: subtle,
        letterSpacing: 0.3,
      ),
      labelSmall: base.labelSmall?.copyWith(
        color: subtle,
        letterSpacing: 0.4,
      ),
    );
  }
}
