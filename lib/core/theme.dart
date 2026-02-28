import 'package:flutter/material.dart';

class AppTheme {
  // Gece modu tarzı mat ve koyu arkaplan
  static const Color backgroundColor = Color(0xFF16161B); // Biraz daha koyu
  
  // Gridin (oyun tahtasının) hücre rengi
  static const Color gridCellColor = Color(0xFF22242D); // Oyuklara daha koyu zemin
  static const Color gridOutlineColor = Color(0xFF2B2D37);

  // Bloklar için klasik (2D) ve pastel renkler
  static const List<Color> classicBlockColors = [
    Color(0xFFFF6B6B), // Pastel Kırmızı
    Color(0xFF4D96FF), // Pastel Mavi
    Color(0xFF6BCB77), // Pastel Yeşil
    Color(0xFFFFD93D), // Sarı/Turuncu Pastel
    Color(0xFFB19CD9), // Pastel Mor
    Color(0xFF4DD0E1), // Pastel Turkuaz
  ];

  // Bloklar için aşırı canlı, doygun mücevher/kristal renkleri (3D için)
  static const List<Color> jewelBlockColors = [
    Color(0xFFFF0000), // Saf Parlak Kırmızı
    Color(0xFF0055FF), // Saf Derin Mavi
    Color(0xFF00FF00), // Fosforlu Yeşil
    Color(0xFFFF8C00), // Parlak Canlı Turuncu
    Color(0xFFD500F9), // Koyu Neon Mor
    Color(0xFF00FFFF), // Camgöbeği (Cyan)
  ];

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
      fontFamily: 'Roboto', // Modern sans-serif tavsiye edilir
    );
  }
}
