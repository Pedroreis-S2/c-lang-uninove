import 'package:flutter/material.dart';

// Aparencia do app. A cor-base define a paleta; trocar ela muda a identidade.
class Tema {
  static const Color corBase = Color(0xFF7C4DFF);
  static const Color corAcento = Color(0xFFFF8A65);
  static const double raio = 20;
  static const double espaco = 16;
  static const double larguraMaxima = 560;

  // A partir desta largura o app troca o menu de baixo pelo menu lateral.
  static const double larguraTela = 840;

  static ThemeData claro() {
    return _montar(Brightness.light, const Color(0xFFF6F2FF), Colors.white);
  }

  static ThemeData escuro() {
    return _montar(Brightness.dark, const Color(0xFF141218), const Color(0xFF211F26));
  }

  static ThemeData _montar(Brightness brilho, Color fundo, Color cartao) {
    final esquema = ColorScheme.fromSeed(
      seedColor: corBase,
      brightness: brilho,
      secondary: corAcento,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: fundo,
      cardTheme: CardTheme(
        elevation: 0,
        color: cartao,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(raio),
          side: BorderSide(color: esquema.outlineVariant.withOpacity(0.45)),
        ),
      ),
      chipTheme: ChipThemeData(
        showCheckmark: false,
        shape: const StadiumBorder(),
        side: BorderSide(color: esquema.outlineVariant),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cartao,
        indicatorColor: corBase.withOpacity(0.18),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: cartao,
        indicatorColor: corBase.withOpacity(0.18),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cartao,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(raio),
          borderSide: BorderSide.none,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  // Cores de cada situacao de consulta.
  static Color corStatus(String status) {
    switch (status) {
      case 'CONCLUIDA':
        return const Color(0xFF43A047);
      case 'CANCELADA':
        return const Color(0xFFE53935);
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
