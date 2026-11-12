import 'package:flutter/material.dart';

// Retrato ilustrado de um pet (cachorro, gato ou outro), desenhado na mao.
// A cor do pelo vem do nome, entao cada pet tem sempre o mesmo visual.
// Quando existir foto de verdade (upload do tutor), ela entra no lugar.
class AvatarPet extends StatelessWidget {
  final String nome;
  final String especie;
  final double tamanho;

  const AvatarPet({
    super.key,
    required this.nome,
    required this.especie,
    this.tamanho = 52,
  });

  static const List<Color> _pelagens = [
    Color(0xFFD7A86E),
    Color(0xFF8D6E63),
    Color(0xFFBDBDBD),
    Color(0xFFFFCC80),
    Color(0xFF6D6D78),
    Color(0xFFF5E6D3),
  ];

  static const List<Color> _fundos = [
    Color(0xFFE8DEFF),
    Color(0xFFFFE0D6),
    Color(0xFFD6F2E3),
    Color(0xFFD9ECFF),
  ];

  int get _semente {
    var soma = 0;
    for (final codigo in nome.codeUnits) {
      soma = soma + codigo;
    }
    return soma;
  }

  @override
  Widget build(BuildContext context) {
    final pelagem = _pelagens[_semente % _pelagens.length];
    final fundo = _fundos[_semente % _fundos.length];
    final minuscula = especie.toLowerCase();
    var tipo = _TipoPet.outro;
    if (minuscula.contains('cachorro') || minuscula.contains('cao')) {
      tipo = _TipoPet.cachorro;
    }
    if (minuscula.contains('gato')) {
      tipo = _TipoPet.gato;
    }
    return SizedBox(
      width: tamanho,
      height: tamanho,
      child: CustomPaint(painter: _RetratoPainter(tipo, pelagem, fundo)),
    );
  }
}

enum _TipoPet { cachorro, gato, outro }

class _RetratoPainter extends CustomPainter {
  final _TipoPet tipo;
  final Color pelagem;
  final Color fundo;

  _RetratoPainter(this.tipo, this.pelagem, this.fundo);

  @override
  void paint(Canvas canvas, Size size) {
    final lado = size.width;
    final centro = Offset(lado / 2, lado / 2);
    final tinta = Paint()..style = PaintingStyle.fill;

    tinta.color = fundo;
    canvas.drawCircle(centro, lado / 2, tinta);

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: centro, radius: lado / 2)));

    final rosto = Offset(lado / 2, lado * 0.56);
    final raioRosto = lado * 0.3;
    final pelagemEscura = Color.lerp(pelagem, Colors.black, 0.18)!;

    _orelhas(canvas, tinta, lado, rosto, raioRosto, pelagemEscura);

    tinta.color = pelagem;
    canvas.drawCircle(rosto, raioRosto, tinta);

    _focinho(canvas, tinta, lado, rosto, raioRosto);
    _olhos(canvas, tinta, lado, rosto, raioRosto);
    canvas.restore();
  }

  void _orelhas(Canvas canvas, Paint tinta, double lado, Offset rosto,
      double raioRosto, Color cor) {
    tinta.color = cor;
    if (tipo == _TipoPet.gato) {
      final esquerda = Path()
        ..moveTo(rosto.dx - raioRosto * 0.95, rosto.dy - raioRosto * 0.1)
        ..lineTo(rosto.dx - raioRosto * 0.8, rosto.dy - raioRosto * 1.45)
        ..lineTo(rosto.dx - raioRosto * 0.1, rosto.dy - raioRosto * 0.85)
        ..close();
      final direita = Path()
        ..moveTo(rosto.dx + raioRosto * 0.95, rosto.dy - raioRosto * 0.1)
        ..lineTo(rosto.dx + raioRosto * 0.8, rosto.dy - raioRosto * 1.45)
        ..lineTo(rosto.dx + raioRosto * 0.1, rosto.dy - raioRosto * 0.85)
        ..close();
      canvas.drawPath(esquerda, tinta);
      canvas.drawPath(direita, tinta);
      return;
    }
    final largura = raioRosto * 0.7;
    final altura = raioRosto * 1.3;
    final esquerda = Rect.fromCenter(
      center: Offset(rosto.dx - raioRosto * 0.95, rosto.dy - raioRosto * 0.15),
      width: largura,
      height: altura,
    );
    final direita = Rect.fromCenter(
      center: Offset(rosto.dx + raioRosto * 0.95, rosto.dy - raioRosto * 0.15),
      width: largura,
      height: altura,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(esquerda, Radius.circular(largura)), tinta);
    canvas.drawRRect(RRect.fromRectAndRadius(direita, Radius.circular(largura)), tinta);
  }

  void _focinho(Canvas canvas, Paint tinta, double lado, Offset rosto,
      double raioRosto) {
    tinta.color = const Color(0xFFFFF3E6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(rosto.dx, rosto.dy + raioRosto * 0.35),
        width: raioRosto * 1.2,
        height: raioRosto * 0.85,
      ),
      tinta,
    );
    tinta.color = const Color(0xFF4A3A3A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(rosto.dx, rosto.dy + raioRosto * 0.15),
        width: raioRosto * 0.34,
        height: raioRosto * 0.24,
      ),
      tinta,
    );
    final boca = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lado * 0.018
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF4A3A3A);
    final caminho = Path()
      ..moveTo(rosto.dx, rosto.dy + raioRosto * 0.27)
      ..lineTo(rosto.dx, rosto.dy + raioRosto * 0.45)
      ..moveTo(rosto.dx - raioRosto * 0.22, rosto.dy + raioRosto * 0.55)
      ..quadraticBezierTo(rosto.dx - raioRosto * 0.1, rosto.dy + raioRosto * 0.45,
          rosto.dx, rosto.dy + raioRosto * 0.45)
      ..quadraticBezierTo(rosto.dx + raioRosto * 0.1, rosto.dy + raioRosto * 0.45,
          rosto.dx + raioRosto * 0.22, rosto.dy + raioRosto * 0.55);
    canvas.drawPath(caminho, boca);
  }

  void _olhos(Canvas canvas, Paint tinta, double lado, Offset rosto,
      double raioRosto) {
    final raioOlho = raioRosto * 0.13;
    final alturaOlho = rosto.dy - raioRosto * 0.15;
    tinta.color = const Color(0xFF2B2230);
    canvas.drawCircle(Offset(rosto.dx - raioRosto * 0.42, alturaOlho), raioOlho, tinta);
    canvas.drawCircle(Offset(rosto.dx + raioRosto * 0.42, alturaOlho), raioOlho, tinta);
    tinta.color = Colors.white;
    canvas.drawCircle(
      Offset(rosto.dx - raioRosto * 0.38, alturaOlho - raioOlho * 0.4),
      raioOlho * 0.35,
      tinta,
    );
    canvas.drawCircle(
      Offset(rosto.dx + raioRosto * 0.46, alturaOlho - raioOlho * 0.4),
      raioOlho * 0.35,
      tinta,
    );
  }

  @override
  bool shouldRepaint(covariant _RetratoPainter antigo) {
    return antigo.tipo != tipo || antigo.pelagem != pelagem || antigo.fundo != fundo;
  }
}
