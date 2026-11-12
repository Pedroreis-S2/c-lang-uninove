import 'package:flutter/material.dart';

import '../config/textos.dart';
import 'logo.dart';

// Barra do topo: logo da clinica a esquerda e as acoes a direita.
class BarraApp extends StatelessWidget {
  final bool escuro;
  final VoidCallback aoAtualizar;
  final VoidCallback aoAlternarTema;

  const BarraApp({
    super.key,
    required this.escuro,
    required this.aoAtualizar,
    required this.aoAlternarTema,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    var iconeTema = Icons.dark_mode_outlined;
    var dicaTema = Textos.temaEscuro;
    if (escuro) {
      iconeTema = Icons.light_mode_outlined;
      dicaTema = Textos.temaClaro;
    }
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(
          bottom: BorderSide(color: esquema.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          const LogoUninoVet(tamanho: 40),
          const Spacer(),
          IconButton(
            tooltip: Textos.atualizar,
            onPressed: aoAtualizar,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: dicaTema,
            onPressed: aoAlternarTema,
            icon: Icon(iconeTema),
          ),
          const SizedBox(width: 6),
          CircleAvatar(
            radius: 18,
            backgroundColor: esquema.primaryContainer,
            child: Text(
              'GE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: esquema.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
