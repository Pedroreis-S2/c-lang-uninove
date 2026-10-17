import 'package:flutter/material.dart';

import '../config/tema.dart';

// Centraliza o conteudo e limita a largura, para a tela ficar boa no celular
// e no navegador.
class Conteudo extends StatelessWidget {
  final Widget child;

  const Conteudo({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Tema.larguraMaxima),
        child: child,
      ),
    );
  }
}
