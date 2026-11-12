import 'package:flutter/material.dart';

import '../config/tema.dart';
import '../config/textos.dart';

// Mensagem no meio da tela: carregando, vazio ou erro.
class Aviso extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String texto;
  final bool mostrarProgresso;
  final Future<void> Function()? aoTentar;

  const Aviso({
    super.key,
    required this.icone,
    required this.titulo,
    this.texto = '',
    this.mostrarProgresso = false,
    this.aoTentar,
  });

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 56, color: Tema.corBase.withOpacity(0.6)),
            const SizedBox(height: 16),
            Text(titulo, style: estilo.titleMedium, textAlign: TextAlign.center),
            if (texto.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                texto,
                style: estilo.bodySmall?.copyWith(color: esquema.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
            if (mostrarProgresso) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],
            if (aoTentar != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: aoTentar,
                icon: const Icon(Icons.refresh),
                label: const Text(Textos.tentarNovamente),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
