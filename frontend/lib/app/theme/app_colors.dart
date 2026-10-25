import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Root Backgrounds
  static const Color bgRoot = Color(0xFFFBF8F3);
  static const Color bgSecondary = Color(0xFFF5EFEB);
  static const Color surfaceCanvas = Color(0xFFFFFFFF);

  // Brand Accents
  static const Color primaryCoral = Color(0xFFFF5733);
  static const Color primaryCoralLight = Color(0xFFFF6B4A);
  static const Color primaryFixed = Color(0xFFFFDAD3);
  static const Color accentMint = Color(0xFF2EC4B6);
  static const Color accentMintBright = Color(0xFF38D9A9);
  static const Color accentYellow = Color(0xFFFFD166);
  static const Color accentLavender = Color(0xFFB8A9C9);
  static const Color accentLavenderSubtle = Color(0xFFE8E0F0);

  // Material / Stitch Semantic Tokens from DESIGN.md
  static const Color secondary = Color(0xFF006A62);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF70F8E8);
  static const Color onSecondaryContainer = Color(0xFF007168);
  static const Color tertiary = Color(0xFF785A00);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFB38C27);
  static const Color onTertiaryContainer = Color(0xFF382800);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFF22252A);
  static const Color textSecondary = Color(0xFF636B78);
  static const Color textMuted = Color(0xFF9AA0A6);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Glass & Borders
  static const Color borderGlass = Color(0xB3FFFFFF); // 70% opacity white
  static const Color borderSubtle = Color(0x14281E14); // rgba(40, 30, 20, 0.08)
  static const Color outlineVariant = Color(0xFFE4BEB6);
  static const Color glassWhite = Color(0xE6FFFFFF); // 90% opacity white
  static const Color glassWhiteTranslucent = Color(0xD9FFFFFF); // 85% opacity
  static const Color glassSubtle = Color(0xA6FFFFFF); // 65% opacity
  static const Color surfaceContainerLow = Color(0xFFF6F3EE);
  static const Color surfaceContainer = Color(0xFFF0EDE9);
  static const Color surfaceContainerHigh = Color(0xFFEBE8E3);
  static const Color surfaceContainerHighest = Color(0xFFE5E2DD);

  // Status
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // Gradients
  static const LinearGradient coralGradient = LinearGradient(
    colors: [primaryCoralLight, primaryCoral, Color(0xFFFFA07A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintGradient = LinearGradient(
    colors: [accentMint, accentMintBright],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Soft Warm Glass Shadow
  static List<BoxShadow> get glassShadow => [
    BoxShadow(
      color: const Color(0xFFB49682).withValues(alpha: 0.14),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0xFFB49682).withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get coralButtonShadow => [
    BoxShadow(
      color: primaryCoral.withValues(alpha: 0.35),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get mintButtonShadow => [
    BoxShadow(
      color: accentMint.withValues(alpha: 0.35),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];
}
