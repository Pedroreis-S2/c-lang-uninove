import 'package:flutter/material.dart';

import '../config/tema.dart';
import '../config/textos.dart';
import '../modelos/agendamento.dart';
import '../servicos/sessao.dart';
import '../widgets/avatar_pet.dart';
import '../widgets/patinha.dart';

// Primeira tela: resumo da clinica com numeros, situacao e proximas consultas.
class PaginaInicio extends StatelessWidget {
  final List<Agendamento> agendamentos;
  final bool larga;

  const PaginaInicio({
    super.key,
    required this.agendamentos,
    required this.larga,
  });

  int _contar(String status) {
    var total = 0;
    for (final agendamento in agendamentos) {
      if (agendamento.status == status) {
        total = total + 1;
      }
    }
    return total;
  }

  List<Agendamento> get _proximas {
    final proximas = <Agendamento>[];
    for (final agendamento in agendamentos) {
      if (agendamento.status == 'AGENDADA') {
        proximas.add(agendamento);
      }
    }
    if (proximas.length > 4) {
      return proximas.sublist(0, 4);
    }
    return proximas;
  }

  Map<String, int> get _porVeterinario {
    final contagem = <String, int>{};
    for (final agendamento in agendamentos) {
      final atual = contagem[agendamento.veterinario] ?? 0;
      contagem[agendamento.veterinario] = atual + 1;
    }
    return contagem;
  }

  @override
  Widget build(BuildContext context) {
    final blocoProximas = _CartaoProximas(proximas: _proximas);
    final blocoVeterinarios = _CartaoVeterinarios(contagem: _porVeterinario);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: const EdgeInsets.all(Tema.espaco),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Boasvindas(),
                    const SizedBox(height: 24),
                    const _Secao(Textos.resumoTitulo),
                    _Numeros(
                      total: agendamentos.length,
                      agendadas: _contar('AGENDADA'),
                      concluidas: _contar('CONCLUIDA'),
                      canceladas: _contar('CANCELADA'),
                    ),
                    const SizedBox(height: 24),
                    const _Secao(Textos.situacaoTitulo),
                    _BarraSituacao(
                      agendadas: _contar('AGENDADA'),
                      concluidas: _contar('CONCLUIDA'),
                      canceladas: _contar('CANCELADA'),
                    ),
                    const SizedBox(height: 24),
                    if (larga)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: blocoProximas),
                          const SizedBox(width: Tema.espaco),
                          Expanded(child: blocoVeterinarios),
                        ],
                      )
                    else
                      Column(
                        children: [
                          blocoProximas,
                          const SizedBox(height: Tema.espaco),
                          blocoVeterinarios,
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Boasvindas extends StatelessWidget {
  const _Boasvindas();

  // Logado: "Olá, Ana". Sem login (testes) mantem o texto da equipe.
  String _saudacao() {
    final usuario = Sessao.usuario;
    if (usuario == null) {
      return Textos.saudacao;
    }
    final primeiroNome = usuario.nome.trim().split(' ').first;
    return 'Olá, $primeiroNome';
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Tema.corBase, Color(0xFFB388FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -10,
            bottom: -20,
            child: Opacity(
              opacity: 0.18,
              child: Patinha(tamanho: 120, cor: Colors.white),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _saudacao(),
                style: texto.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                Textos.slogan,
                style: texto.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  final String titulo;

  const _Secao(this.titulo);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        titulo,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _Numeros extends StatelessWidget {
  final int total;
  final int agendadas;
  final int concluidas;
  final int canceladas;

  const _Numeros({
    required this.total,
    required this.agendadas,
    required this.concluidas,
    required this.canceladas,
  });

  @override
  Widget build(BuildContext context) {
    final cartoes = <Widget>[
      _Numero(
        icone: Icons.event_note,
        rotulo: Textos.totalConsultas,
        valor: total,
        cor: Tema.corBase,
      ),
      _Numero(
        icone: Icons.schedule,
        rotulo: Tema.rotuloStatus('AGENDADA'),
        valor: agendadas,
        cor: Tema.corStatus('AGENDADA'),
      ),
      _Numero(
        icone: Icons.check_circle,
        rotulo: Tema.rotuloStatus('CONCLUIDA'),
        valor: concluidas,
        cor: Tema.corStatus('CONCLUIDA'),
      ),
      _Numero(
        icone: Icons.cancel,
        rotulo: Tema.rotuloStatus('CANCELADA'),
        valor: canceladas,
        cor: Tema.corStatus('CANCELADA'),
      ),
    ];
    return LayoutBuilder(
      builder: (context, restricoes) {
        final colunas = restricoes.maxWidth >= 700 ? 4 : 2;
        const espaco = 12.0;
        final largura = (restricoes.maxWidth - espaco * (colunas - 1)) / colunas;
        return Wrap(
          spacing: espaco,
          runSpacing: espaco,
          children: [
            for (final cartao in cartoes) SizedBox(width: largura, child: cartao),
          ],
        );
      },
    );
  }
}

class _Numero extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final int valor;
  final Color cor;

  const _Numero({
    required this.icone,
    required this.rotulo,
    required this.valor,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Tema.espaco),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: cor.withOpacity(0.15),
              child: Icon(icone, color: cor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$valor',
                    style: texto.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    rotulo,
                    overflow: TextOverflow.ellipsis,
                    style: texto.bodySmall?.copyWith(color: esquema.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Barra dividida em tres cores, cada pedaco proporcional ao numero de consultas.
class _BarraSituacao extends StatelessWidget {
  final int agendadas;
  final int concluidas;
  final int canceladas;

  const _BarraSituacao({
    required this.agendadas,
    required this.concluidas,
    required this.canceladas,
  });

  @override
  Widget build(BuildContext context) {
    final pedacos = <Widget>[];
    final valores = <String, int>{
      'AGENDADA': agendadas,
      'CONCLUIDA': concluidas,
      'CANCELADA': canceladas,
    };
    for (final entrada in valores.entries) {
      if (entrada.value == 0) {
        continue;
      }
      pedacos.add(
        Expanded(
          flex: entrada.value,
          child: Container(height: 14, color: Tema.corStatus(entrada.key)),
        ),
      );
    }
    if (pedacos.isEmpty) {
      return const SizedBox(height: 14);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Row(children: pedacos),
    );
  }
}

class _CartaoProximas extends StatelessWidget {
  final List<Agendamento> proximas;

  const _CartaoProximas({required this.proximas});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final linhas = <Widget>[];
    for (final consulta in proximas) {
      linhas.add(
        ListTile(
          leading: AvatarPet(
            nome: consulta.animal,
            especie: consulta.especie,
            tamanho: 44,
          ),
          title: Text(consulta.animal),
          subtitle: Text('${consulta.motivo} · ${consulta.veterinario}'),
          trailing: Text(
            '${consulta.diaFormatado}\n${consulta.hora}',
            textAlign: TextAlign.right,
            style: TextStyle(color: esquema.onSurfaceVariant, fontSize: 12),
          ),
        ),
      );
    }
    if (linhas.isEmpty) {
      linhas.add(const ListTile(title: Text(Textos.proximasVazio)));
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Text(
                Textos.proximasTitulo,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...linhas,
          ],
        ),
      ),
    );
  }
}

class _CartaoVeterinarios extends StatelessWidget {
  final Map<String, int> contagem;

  const _CartaoVeterinarios({required this.contagem});

  @override
  Widget build(BuildContext context) {
    var maior = 1;
    for (final quantidade in contagem.values) {
      if (quantidade > maior) {
        maior = quantidade;
      }
    }
    final linhas = <Widget>[];
    for (final entrada in contagem.entries) {
      linhas.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(entrada.key)),
                  Text(Textos.contagem(entrada.value)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: entrada.value / maior,
                  minHeight: 10,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Tema.espaco),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Textos.veterinariosTitulo,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            ...linhas,
          ],
        ),
      ),
    );
  }
}
