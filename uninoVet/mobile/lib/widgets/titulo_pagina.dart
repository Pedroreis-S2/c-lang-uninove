import 'package:flutter/material.dart';

// Titulo grande no alto de cada pagina, com um subtitulo mais suave.
class TituloPagina extends StatelessWidget {
  final String titulo;
  final String subtitulo;

  const TituloPagina({super.key, required this.titulo, required this.subtitulo});

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: texto.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitulo,
            style: texto.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
