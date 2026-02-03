import 'package:flutter/material.dart';

/// JARVIS-inspired color palette
class JarvisColors {
  // Primary colors
  static const Color primary = Color(0xFF00D4FF);        // Cyan glow
  static const Color secondary = Color(0xFFFF6B00);      // Orange accent
  static const Color tertiary = Color(0xFF00FF88);       // Green success
  
  // Background colors
  static const Color background = Color(0xFF0A0E17);     // Deep dark blue
  static const Color surface = Color(0xFF111827);        // Card backgrounds
  static const Color surfaceLight = Color(0xFF1F2937);   // Elevated surfaces
  
  // Glow colors
  static const Color glowCyan = Color(0xFF00D4FF);
  static const Color glowOrange = Color(0xFFFF6B00);
  static const Color glowBlue = Color(0xFF3B82F6);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF7DD3FC);
  static const Color textMuted = Color(0xFF64748B);
  
  // Status colors
  static const Color success = Color(0xFF00FF88);
  static const Color warning = Color(0xFFFFAA00);
  static const Color error = Color(0xFFFF4444);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF0066FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A2332), Color(0xFF0F1419)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const RadialGradient glowGradient = RadialGradient(
    colors: [Color(0x4000D4FF), Color(0x0000D4FF)],
    radius: 0.8,
  );
}

/// JARVIS-inspired text styles
class JarvisTextStyles {
  static const String fontFamily = 'Orbitron';
  
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: JarvisColors.textPrimary,
    letterSpacing: 4,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: JarvisColors.textPrimary,
    letterSpacing: 2,
  );
  
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: JarvisColors.textPrimary,
    letterSpacing: 1.5,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: JarvisColors.textPrimary,
    letterSpacing: 1,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: JarvisColors.textSecondary,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: JarvisColors.textSecondary,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: JarvisColors.primary,
    letterSpacing: 1.2,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: JarvisColors.textMuted,
  );
}

/// Main JARVIS theme
class JarvisTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: JarvisColors.background,
      primaryColor: JarvisColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: JarvisColors.primary,
        secondary: JarvisColors.secondary,
        surface: JarvisColors.surface,
        error: JarvisColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: JarvisTextStyles.headlineMedium,
        iconTheme: IconThemeData(color: JarvisColors.primary),
      ),
      cardTheme: CardTheme(
        color: JarvisColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: JarvisColors.primary,
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: JarvisColors.primary,
          foregroundColor: JarvisColors.background,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: JarvisTextStyles.labelLarge.copyWith(
            color: JarvisColors.background,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: JarvisColors.primary,
          side: const BorderSide(color: JarvisColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: JarvisColors.primary,
        foregroundColor: JarvisColors.background,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return JarvisColors.primary;
          }
          return JarvisColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return JarvisColors.primary.withOpacity(0.3);
          }
          return JarvisColors.surfaceLight;
        }),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: JarvisColors.primary,
        inactiveTrackColor: JarvisColors.surfaceLight,
        thumbColor: JarvisColors.primary,
        overlayColor: Color(0x2900D4FF),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: JarvisColors.surface,
        hourMinuteTextColor: JarvisColors.primary,
        dialHandColor: JarvisColors.primary,
        dialBackgroundColor: JarvisColors.surfaceLight,
        dialTextColor: JarvisColors.textPrimary,
        entryModeIconColor: JarvisColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: JarvisColors.primary, width: 2),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: JarvisTextStyles.displayLarge,
        displayMedium: JarvisTextStyles.displayMedium,
        headlineLarge: JarvisTextStyles.headlineLarge,
        headlineMedium: JarvisTextStyles.headlineMedium,
        bodyLarge: JarvisTextStyles.bodyLarge,
        bodyMedium: JarvisTextStyles.bodyMedium,
        labelLarge: JarvisTextStyles.labelLarge,
      ),
    );
  }
}
