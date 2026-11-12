import 'package:flutter/material.dart';

import '../config/tema.dart';
import '../config/textos.dart';
import '../modelos/agendamento.dart';
import '../modelos/opcoes.dart';
import '../widgets/aviso.dart';
import '../widgets/avatar_pet.dart';
import '../widgets/titulo_pagina.dart';

// Um pet e o historico de consultas dele, montado a partir dos agendamentos.
class _Pet {
  final String nome;
  final String especie;
  final List<Agendamento> consultas = <Agendamento>[];

  _Pet({required this.nome, required this.especie});
}

// Galeria de pets atendidos pela clinica, em grade que se ajusta a largura.
class PaginaPets extends StatelessWidget {
  final List<Agendamento> agendamentos;

  // Pets cadastrados pelo tutor (aparecem mesmo sem nenhuma consulta).
  final List<Pet> petsCadastrados;

  const PaginaPets({
    super.key,
    required this.agendamentos,
    this.petsCadastrados = const <Pet>[],
  });

  List<_Pet> get _pets {
    final porNome = <String, _Pet>{};
    for (final cadastrado in petsCadastrados) {
      final chave = '${cadastrado.nome}|${cadastrado.especie}';
      porNome[chave] = _Pet(nome: cadastrado.nome, especie: cadastrado.especie);
    }
    for (final agendamento in agendamentos) {
      final chave = '${agendamento.animal}|${agendamento.especie}';
      var pet = porNome[chave];
      if (pet == null) {
        pet = _Pet(nome: agendamento.animal, especie: agendamento.especie);
        porNome[chave] = pet;
      }
      pet.consultas.add(agendamento);
    }
    return porNome.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final pets = _pets;
    final cartoes = <Widget>[];
    for (final pet in pets) {
      cartoes.add(_CartaoPet(pet: pet));
    }
    Widget corpo = const Aviso(
      icone: Icons.pets,
      titulo: Textos.petsVazio,
    );
    if (cartoes.isNotEmpty) {
      corpo = GridView(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 320,
          mainAxisExtent: 150,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        padding: const EdgeInsets.all(Tema.espaco),
        children: cartoes,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TituloPagina(
          titulo: Textos.petsTitulo,
          subtitulo: Textos.petsSubtitulo,
        ),
        Expanded(child: corpo),
      ],
    );
  }
}

class _CartaoPet extends StatelessWidget {
  final _Pet pet;

  const _CartaoPet({required this.pet});

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    final temConsulta = pet.consultas.isNotEmpty;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Tema.espaco),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarPet(nome: pet.nome, especie: pet.especie, tamanho: 56),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.nome,
                        style: texto.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        pet.especie,
                        style: texto.bodySmall?.copyWith(
                          color: esquema.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              Textos.contagem(pet.consultas.length),
              style: texto.labelLarge?.copyWith(color: esquema.primary),
            ),
            const SizedBox(height: 2),
            if (temConsulta)
              Text(
                '${Textos.ultimaConsulta}: ${pet.consultas.last.diaFormatado} · ${pet.consultas.last.motivo}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: texto.bodySmall?.copyWith(color: esquema.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }
}
