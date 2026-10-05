import 'package:flutter/material.dart';

/// Palette « terre » : sans Google Fonts pour fonctionner hors ligne.
class AppTheme {
  static const Color primaryColor = Color(0xFF8D5524);
  static const Color secondaryColor = Color(0xFF5B8C3A);
  static const Color backgroundColor = Color(0xFFF7F3EE);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFB00020);
  static const Color infoColor = Color(0xFF2E7DAF);

  /// Couleur indicative par classe (I à XII).
  static const List<Color> classColors = [
    Color(0xFF9E9E9E),
    Color(0xFFBCAAA4),
    Color(0xFF424242),
    Color(0xFF37474F),
    Color(0xFFD7CCC8),
    Color(0xFF5D4037),
    Color(0xFF8D6E63),
    Color(0xFF90A4AE),
    Color(0xFFD84315),
    Color(0xFFB71C1C),
    Color(0xFF546E7A),
    Color(0xFFE0E0E0),
  ];

  static Color colorForCode(String code) {
    const romans = [
      'I',
      'II',
      'III',
      'IV',
      'V',
      'VI',
      'VII',
      'VIII',
      'IX',
      'X',
      'XI',
      'XII',
    ];
    final index = romans.indexOf(code.split('.').first);
    return index < 0 ? primaryColor : classColors[index];
  }

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        shape: Border(),
        collapsedShape: Border(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
