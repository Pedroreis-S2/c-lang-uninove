import 'package:flutter/material.dart';

import 'aulas/aula07_telas.dart';
import 'config/strings.dart';
import 'config/tema.dart';

void main() {
  runApp(const EstudaeApp());
}

class EstudaeApp extends StatelessWidget {
  const EstudaeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Textos.nomeApp,
      debugShowCheckedModeBanner: false,
      theme: Tema.claro(),
      darkTheme: Tema.escuro(),
      home: const TelaInicio(),
    );
  }
}
