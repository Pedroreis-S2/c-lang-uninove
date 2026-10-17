import 'package:flutter/material.dart';

import '../config/tema.dart';
import '../config/textos.dart';
import '../modelos/agendamento.dart';
import '../servicos/api.dart';
import '../widgets/cartao_agendamento.dart';
import '../widgets/patinha.dart';

class PaginaAgendamentos extends StatefulWidget {
  const PaginaAgendamentos({super.key});

  @override
  State<PaginaAgendamentos> createState() => _PaginaAgendamentosState();
}

class _PaginaAgendamentosState extends State<PaginaAgendamentos> {
  final Api _api = Api();

  List<Agendamento> _agendamentos = <Agendamento>[];
  bool _carregando = true;
  bool _erro = false;
  String _filtro = 'TODOS';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = false;
    });
    try {
      final lista = await _api.buscarAgendamentos();
      if (!mounted) {
        return;
      }
      setState(() {
        _agendamentos = lista;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _erro = true;
        _carregando = false;
      });
    }
  }

  void _mudarFiltro(String filtro) {
    setState(() {
      _filtro = filtro;
    });
  }

  List<Agendamento> get _visiveis {
    if (_filtro == 'TODOS') {
      return _agendamentos;
    }
    return _agendamentos.where((a) => a.status == _filtro).toList();
  }

  void _abrirDetalhe(Agendamento agendamento) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => _Detalhe(agendamento: agendamento),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Tema.larguraMaxima),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Cabecalho(),
                _BarraFiltros(filtro: _filtro, aoMudar: _mudarFiltro),
                Expanded(child: _corpo()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _corpo() {
    if (_carregando) {
      return const _Aviso(
        icone: Icons.pets,
        titulo: Textos.carregando,
        texto: '',
        mostrarProgresso: true,
      );
    }
    if (_erro) {
      return _Aviso(
        icone: Icons.wifi_off,
        titulo: Textos.erroTitulo,
        texto: Textos.erroTexto,
        aoTentar: _carregar,
      );
    }
    final visiveis = _visiveis;
    if (visiveis.isEmpty) {
      return const _Aviso(
        icone: Icons.event_busy,
        titulo: Textos.vazioTitulo,
        texto: Textos.vazioTexto,
      );
    }
    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView.separated(
        padding: const EdgeInsets.all(Tema.espaco),
        itemCount: visiveis.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return CartaoAgendamento(
            agendamento: visiveis[index],
            aoTocar: _abrirDetalhe,
          );
        },
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho();

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(Tema.espaco, Tema.espaco, Tema.espaco, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Tema.corBase, Color(0xFF9575FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Patinha(tamanho: 36, cor: Tema.corBase),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Textos.nomeClinica,
                style: texto.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                Textos.slogan,
                style: texto.bodySmall?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarraFiltros extends StatelessWidget {
  final String filtro;
  final void Function(String filtro) aoMudar;

  const _BarraFiltros({required this.filtro, required this.aoMudar});

  @override
  Widget build(BuildContext context) {
    final opcoes = <String, String>{
      'TODOS': Textos.filtroTodos,
      'AGENDADA': 'Agendadas',
      'CONCLUIDA': 'Concluídas',
      'CANCELADA': 'Canceladas',
    };
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Tema.espaco),
        children: opcoes.entries.map((opcao) {
          final selecionado = filtro == opcao.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(opcao.value),
              selected: selecionado,
              onSelected: (_) => aoMudar(opcao.key),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String texto;
  final bool mostrarProgresso;
  final Future<void> Function()? aoTentar;

  const _Aviso({
    required this.icone,
    required this.titulo,
    required this.texto,
    this.mostrarProgresso = false,
    this.aoTentar,
  });

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme;
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
                style: estilo.bodySmall?.copyWith(color: Colors.black54),
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

class _Detalhe extends StatelessWidget {
  final Agendamento agendamento;

  const _Detalhe({required this.agendamento});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Patinha(tamanho: 28, cor: Tema.corBase),
              const SizedBox(width: 10),
              Text(
                Textos.detalheTitulo,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _linha(context, Textos.rotuloAnimal, agendamento.animal),
          _linha(context, Textos.rotuloEspecie, agendamento.especie),
          _linha(context, Textos.rotuloVeterinario, agendamento.veterinario),
          _linha(context, Textos.rotuloData, agendamento.dataFormatada),
          _linha(context, Textos.rotuloMotivo, agendamento.motivo),
          _linha(context, Textos.rotuloStatus, Tema.rotuloStatus(agendamento.status)),
        ],
      ),
    );
  }

  Widget _linha(BuildContext context, String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              rotulo,
              style: const TextStyle(color: Colors.black54),
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
