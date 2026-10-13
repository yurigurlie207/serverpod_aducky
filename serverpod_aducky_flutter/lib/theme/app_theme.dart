import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core Color Tokens from Pomodoro Forest Focus
  static const Color deepForest = Color(0xFF0A2923);
  static const Color forestGreen = Color(0xFF164F40);
  static const Color antiqueGold = Color(0xFF9A7B38);
  static const Color antiqueGoldLight = Color(0xFFF2C154);
  static const Color goldenYellow = Color(0xFFF2A900);
  static const Color burntOrange = Color(0xFFCC6F00);
  static const Color deepBrown = Color(0xFF4D2A00);
  static const Color warmLinen = Color(0xFFF3EAD7);
  static const Color cream = Color(0xFFF9E6A8);
  static const Color white = Colors.white;

  static const Color timerTeal = Color(0xFF00695C);
  static const Color darkTeal = Color(0xFF004D40);

  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    const backgroundColor = timerTeal;
    const onSurfaceColor = Colors.white;

    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.fredoka().fontFamily,
      scaffoldBackgroundColor: backgroundColor,
      canvasColor: backgroundColor,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Colors.white,
        onPrimary: timerTeal,
        secondary: goldenYellow,
        onSecondary: deepBrown,
        tertiary: antiqueGoldLight,
        onTertiary: timerTeal,
        error: Color(0xFFFF8A80),
        onError: Color(0xFF490000),
        surface: timerTeal,
        onSurface: Colors.white,
        primaryContainer: Color(0x33FFFFFF), // Transparent white inlay
        onPrimaryContainer: Colors.white,
        secondaryContainer: Color(0x22FFFFFF),
        onSecondaryContainer: Colors.white,
        surfaceContainerHighest: Color(0x26FFFFFF),
      ),
      textTheme:
          GoogleFonts.fredokaTextTheme(
            ThemeData(brightness: Brightness.dark).textTheme,
          ).apply(
            bodyColor: onSurfaceColor,
            displayColor: onSurfaceColor,
          ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: timerTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(
            color: Colors.white70,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: const Color(0xFF134E42),
          selectedForegroundColor: Colors.white,
          foregroundColor: const Color(0xFF134E42),
          backgroundColor: const Color(0xFFE2EBE6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          side: BorderSide.none,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF004D40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.fredoka(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: GoogleFonts.fredoka(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 14,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: onSurfaceColor,
        textColor: onSurfaceColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: timerTeal,
        foregroundColor: onSurfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: onSurfaceColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.15),
        labelStyle: const TextStyle(color: Colors.white),
        hintStyle: const TextStyle(color: Colors.white60),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}
