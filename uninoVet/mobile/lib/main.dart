import 'package:flutter/material.dart';

import 'config/tema.dart';
import 'config/textos.dart';
import 'paginas/pagina_principal.dart';

void main() {
  runApp(const UninoVetApp());
}

class UninoVetApp extends StatefulWidget {
  const UninoVetApp({super.key});

  @override
  State<UninoVetApp> createState() => _UninoVetAppState();
}

class _UninoVetAppState extends State<UninoVetApp> {
  // Comeca seguindo o tema do aparelho; o menu lateral permite trocar.
  final ValueNotifier<ThemeMode> _modoTema = ValueNotifier<ThemeMode>(ThemeMode.system);

  @override
  void dispose() {
    _modoTema.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _modoTema,
      builder: (context, modo, filho) {
        return MaterialApp(
          title: Textos.nomeClinica,
          debugShowCheckedModeBanner: false,
          theme: Tema.claro(),
          darkTheme: Tema.escuro(),
          themeMode: modo,
          home: PaginaPrincipal(modoTema: _modoTema),
        );
      },
    );
  }
}
