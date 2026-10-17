import 'package:flutter/material.dart';

import '../config/tema.dart';
import '../modelos/agendamento.dart';

// Cartao fofo de um agendamento, com a patinha, os dados e a situacao.
class CartaoAgendamento extends StatelessWidget {
  final Agendamento agendamento;
  final void Function(Agendamento agendamento) aoTocar;

  const CartaoAgendamento({
    super.key,
    required this.agendamento,
    required this.aoTocar,
  });

  void _tocar() {
    aoTocar(agendamento);
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final cor = Tema.corStatus(agendamento.status);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _tocar,
        child: Padding(
          padding: const EdgeInsets.all(Tema.espaco),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Tema.corBase.withOpacity(0.12),
                child: const Icon(Icons.pets, color: Tema.corBase),
              ),
              const SizedBox(width: Tema.espaco),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agendamento.animal,
                      style: texto.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${agendamento.especie} · ${agendamento.veterinario}',
                      style: texto.bodySmall?.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 14, color: Colors.black45),
                        const SizedBox(width: 4),
                        Text(
                          agendamento.dataFormatada,
                          style: texto.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  Tema.rotuloStatus(agendamento.status),
                  style: texto.labelSmall?.copyWith(
                    color: cor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
