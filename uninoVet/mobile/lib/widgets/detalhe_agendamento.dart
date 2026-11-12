import 'package:flutter/material.dart';

import '../config/textos.dart';
import '../modelos/agendamento.dart';
import 'cartao_agendamento.dart';
import 'avatar_pet.dart';

// Detalhes de uma consulta. Aparece numa folha no celular e num painel ao lado
// da lista na tela larga.
class DetalheAgendamento extends StatelessWidget {
  final Agendamento agendamento;

  const DetalheAgendamento({super.key, required this.agendamento});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarPet(
                nome: agendamento.animal,
                especie: agendamento.especie,
                tamanho: 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  Textos.detalheTitulo,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SeloStatus(status: agendamento.status),
            ],
          ),
          const SizedBox(height: 16),
          _linha(context, Textos.rotuloAnimal, agendamento.animal),
          _linha(context, Textos.rotuloEspecie, agendamento.especie),
          _linha(context, Textos.rotuloVeterinario, agendamento.veterinario),
          _linha(context, Textos.rotuloData, agendamento.dataFormatada),
          _linha(context, Textos.rotuloMotivo, agendamento.motivo),
        ],
      ),
    );
  }

  Widget _linha(BuildContext context, String rotulo, String valor) {
    final esquema = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              rotulo,
              style: TextStyle(color: esquema.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
