import 'package:flutter/material.dart';

import '../config/tema.dart';
import '../modelos/agendamento.dart';
import 'avatar_pet.dart';

// Cartao fofo de um agendamento, com a patinha, os dados e a situacao.
class CartaoAgendamento extends StatelessWidget {
  final Agendamento agendamento;
  final void Function(Agendamento agendamento) aoTocar;
  final bool selecionado;

  const CartaoAgendamento({
    super.key,
    required this.agendamento,
    required this.aoTocar,
    this.selecionado = false,
  });

  void _tocar() {
    aoTocar(agendamento);
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    final corBorda = selecionado ? Tema.corBase : Colors.transparent;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Tema.raio),
        border: Border.all(color: corBorda, width: 2),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _tocar,
          child: Padding(
            padding: const EdgeInsets.all(Tema.espaco),
            child: Row(
              children: [
                AvatarPet(
                  nome: agendamento.animal,
                  especie: agendamento.especie,
                  tamanho: 56,
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
                        style: texto.bodySmall?.copyWith(
                          color: esquema.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: esquema.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            agendamento.hora,
                            style: texto.bodySmall,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              agendamento.motivo,
                              overflow: TextOverflow.ellipsis,
                              style: texto.bodySmall?.copyWith(
                                color: esquema.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SeloStatus(status: agendamento.status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Selo colorido com a situacao da consulta.
class SeloStatus extends StatelessWidget {
  final String status;

  const SeloStatus({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final cor = Tema.corStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        Tema.rotuloStatus(status),
        style: texto.labelSmall?.copyWith(
          color: cor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
