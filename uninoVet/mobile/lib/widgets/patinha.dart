import 'package:flutter/material.dart';

// Logo da clinica: uma patinha fofa desenhada na mao (sem imagem externa),
// entao fica nitida em qualquer tamanho e combina com a cor do tema.
class Patinha extends StatelessWidget {
  final double tamanho;
  final Color cor;

  const Patinha({super.key, this.tamanho = 48, required this.cor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamanho,
      height: tamanho,
      child: CustomPaint(painter: _PatinhaPainter(cor)),
    );
  }
}

class _PatinhaPainter extends CustomPainter {
  final Color cor;

  _PatinhaPainter(this.cor);

  @override
  void paint(Canvas canvas, Size size) {
    final tinta = Paint()
      ..color = cor
      ..isAntiAlias = true;
    final largura = size.width;
    final altura = size.height;

    // Almofada central.
    final almofada = Rect.fromCenter(
      center: Offset(largura * 0.5, altura * 0.68),
      width: largura * 0.52,
      height: altura * 0.42,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(almofada, Radius.circular(largura * 0.26)),
      tinta,
    );

    // Quatro dedinhos.
    final dedos = <List<double>>[
      [0.24, 0.34, 0.16, 0.22],
      [0.42, 0.22, 0.17, 0.24],
      [0.60, 0.22, 0.17, 0.24],
      [0.78, 0.34, 0.16, 0.22],
    ];
    for (final d in dedos) {
      final centro = Offset(largura * d[0], altura * d[1]);
      final dedo = Rect.fromCenter(
        center: centro,
        width: largura * d[2],
        height: altura * d[3],
      );
      canvas.drawOval(dedo, tinta);
    }
  }

  @override
  bool shouldRepaint(covariant _PatinhaPainter anterior) {
    return anterior.cor != cor;
  }
}
