import 'package:flutter/material.dart';

import 'config/tema.dart';
import 'config/textos.dart';
import 'paginas/pagina_agendamentos.dart';

void main() {
  runApp(const UninoVetApp());
}

class UninoVetApp extends StatelessWidget {
  const UninoVetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Textos.nomeClinica,
      debugShowCheckedModeBanner: false,
      theme: Tema.claro(),
      home: const PaginaAgendamentos(),
    );
  }
}
