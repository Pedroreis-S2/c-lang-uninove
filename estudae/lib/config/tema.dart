import 'package:flutter/material.dart';

// Aparencia do aplicativo. Troque a cor-base para mudar a identidade visual;
// o restante da paleta (claro e escuro) e gerado a partir dela.
class Tema {
  static const Color corBase = Color(0xFF00796B);
  static const double raio = 16;
  static const double espaco = 16;
  static const double larguraMaxima = 640;

  static ThemeData claro() {
    return _montar(Brightness.light);
  }

  static ThemeData escuro() {
    return _montar(Brightness.dark);
  }

  static ThemeData _montar(Brightness brilho) {
    final esquema = ColorScheme.fromSeed(
      seedColor: corBase,
      brightness: brilho,
    );
    final formaRaio = BorderRadius.circular(raio);
    final formaBotao = RoundedRectangleBorder(borderRadius: formaRaio);
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: esquema.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: esquema.surface,
        foregroundColor: esquema.onSurface,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: esquema.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: esquema.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: formaRaio),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: esquema.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: formaRaio,
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: formaBotao,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: formaBotao,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: formaBotao),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: formaBotao,
      ),
      dialogTheme: DialogTheme(shape: formaBotao),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(raio + 8)),
        ),
      ),
    );
  }
}
