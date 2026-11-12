import 'package:flutter/material.dart';

import '../config/tema.dart';
import '../config/textos.dart';
import 'patinha.dart';

// Marca da clinica: patinha branca num quadrado arredondado em degrade, com um
// coracao coral no canto. Tudo desenhado com widgets, entao fica nitido em
// qualquer tamanho e nao depende de imagem.
class MarcaUninoVet extends StatelessWidget {
  final double tamanho;

  const MarcaUninoVet({super.key, this.tamanho = 44});

  @override
  Widget build(BuildContext context) {
    final tamanhoPatinha = tamanho * 0.58;
    final tamanhoSelo = tamanho * 0.42;
    return SizedBox(
      width: tamanho,
      height: tamanho,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: tamanho,
            height: tamanho,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Tema.corBase, Color(0xFFB388FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(tamanho * 0.32),
              boxShadow: [
                BoxShadow(
                  color: Tema.corBase.withOpacity(0.35),
                  blurRadius: tamanho * 0.3,
                  offset: Offset(0, tamanho * 0.1),
                ),
              ],
            ),
            child: Center(
              child: Patinha(tamanho: tamanhoPatinha, cor: Colors.white),
            ),
          ),
          Positioned(
            right: -tamanho * 0.12,
            top: -tamanho * 0.12,
            child: Container(
              width: tamanhoSelo,
              height: tamanhoSelo,
              decoration: const BoxDecoration(
                color: Tema.corAcento,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite,
                color: Colors.white,
                size: tamanhoSelo * 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Marca + nome "UninoVet" com "Vet" em destaque.
class LogoUninoVet extends StatelessWidget {
  final double tamanho;
  final bool mostrarSlogan;

  const LogoUninoVet({
    super.key,
    this.tamanho = 40,
    this.mostrarSlogan = false,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final texto = Theme.of(context).textTheme;
    final estiloNome = TextStyle(
      fontSize: tamanho * 0.55,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: esquema.onSurface,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MarcaUninoVet(tamanho: tamanho),
        SizedBox(width: tamanho * 0.3),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                style: estiloNome,
                children: const [
                  TextSpan(text: 'Unino'),
                  TextSpan(text: 'Vet', style: TextStyle(color: Tema.corBase)),
                ],
              ),
            ),
            if (mostrarSlogan)
              Text(
                Textos.slogan,
                style: texto.labelSmall?.copyWith(color: esquema.onSurfaceVariant),
              ),
          ],
        ),
      ],
    );
  }
}
