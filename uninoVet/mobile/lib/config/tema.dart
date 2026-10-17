import 'package:flutter/material.dart';

// Aparencia do app. A cor-base define a paleta; trocar ela muda a identidade.
class Tema {
  static const Color corBase = Color(0xFF7C4DFF);
  static const Color corAcento = Color(0xFFFF8A65);
  static const double raio = 20;
  static const double espaco = 16;
  static const double larguraMaxima = 560;

  static ThemeData claro() {
    final esquema = ColorScheme.fromSeed(
      seedColor: corBase,
      primary: corBase,
      secondary: corAcento,
    );
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(raio),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: const Color(0xFFF6F2FF),
      cardTheme: CardTheme(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: forma,
      ),
      chipTheme: const ChipThemeData(showCheckmark: false),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  // Cores de cada situacao de consulta.
  static Color corStatus(String status) {
    switch (status) {
      case 'CONCLUIDA':
        return const Color(0xFF2E7D32);
      case 'CANCELADA':
        return const Color(0xFFC62828);
      default:
        return corBase;
    }
  }

  static String rotuloStatus(String status) {
    switch (status) {
      case 'CONCLUIDA':
        return 'Concluída';
      case 'CANCELADA':
        return 'Cancelada';
      default:
        return 'Agendada';
    }
  }
}
