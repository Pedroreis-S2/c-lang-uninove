import 'package:flutter/material.dart';

import '../config/tema.dart';
import '../config/textos.dart';
import '../modelos/agendamento.dart';
import '../widgets/aviso.dart';
import '../widgets/cartao_agendamento.dart';
import '../widgets/detalhe_agendamento.dart';
import '../widgets/titulo_pagina.dart';

// Agenda da clinica: busca, filtro por situacao e consultas agrupadas por dia.
// No celular o detalhe abre numa folha; na tela larga fica num painel ao lado.
class PaginaAgendamentos extends StatefulWidget {
  final List<Agendamento> agendamentos;
  final bool larga;
  final Future<void> Function(Agendamento agendamento)? aoCancelar;

  const PaginaAgendamentos({
    super.key,
    required this.agendamentos,
    required this.larga,
    this.aoCancelar,
  });

  @override
  State<PaginaAgendamentos> createState() => _PaginaAgendamentosState();
}

class _PaginaAgendamentosState extends State<PaginaAgendamentos> {
  final TextEditingController _busca = TextEditingController();

  String _filtro = 'TODOS';
  String _termo = '';
  Agendamento? _selecionado;

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  void _mudarFiltro(String filtro) {
    setState(() {
      _filtro = filtro;
    });
  }

  void _mudarBusca(String texto) {
    setState(() {
      _termo = texto.trim().toLowerCase();
    });
  }

  bool _combinaComBusca(Agendamento agendamento) {
    if (_termo.isEmpty) {
      return true;
    }
    final animal = agendamento.animal.toLowerCase();
    final veterinario = agendamento.veterinario.toLowerCase();
    final motivo = agendamento.motivo.toLowerCase();
    return animal.contains(_termo) ||
        veterinario.contains(_termo) ||
        motivo.contains(_termo);
  }

  List<Agendamento> get _visiveis {
    final visiveis = <Agendamento>[];
    for (final agendamento in widget.agendamentos) {
      final combinaStatus = _filtro == 'TODOS' || agendamento.status == _filtro;
      if (combinaStatus && _combinaComBusca(agendamento)) {
        visiveis.add(agendamento);
      }
    }
    return visiveis;
  }

  void _abrirDetalhe(Agendamento agendamento) {
    if (widget.larga) {
      setState(() {
        _selecionado = agendamento;
      });
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (contextoFolha) => SingleChildScrollView(
        child: DetalheAgendamento(
          agendamento: agendamento,
          aoCancelar: _acaoDeCancelar(agendamento, fecharFolha: true),
        ),
      ),
    );
  }

  // So existe quando a pagina recebeu a funcao de cancelar (cliente logado).
  VoidCallback? _acaoDeCancelar(Agendamento agendamento, {required bool fecharFolha}) {
    final cancelar = widget.aoCancelar;
    if (cancelar == null) {
      return null;
    }
    return () async {
      if (fecharFolha) {
        Navigator.of(context).pop();
      }
      await cancelar(agendamento);
      if (!mounted) {
        return;
      }
      setState(() {
        _selecionado = null;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    final lista = _montarLista();
    if (!widget.larga) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TituloPagina(
            titulo: Textos.tituloAgendamentos,
            subtitulo: Textos.subtituloAgendamentos,
          ),
          Expanded(child: lista),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TituloPagina(
          titulo: Textos.tituloAgendamentos,
          subtitulo: Textos.subtituloAgendamentos,
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(child: lista),
              SizedBox(width: 380, child: _painelDetalhe()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _painelDetalhe() {
    final selecionado = _selecionado;
    if (selecionado == null) {
      return const Aviso(
        icone: Icons.touch_app,
        titulo: Textos.selecioneConsulta,
      );
    }
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, Tema.espaco, Tema.espaco, Tema.espaco),
        child: Card(
          child: SingleChildScrollView(
            child: DetalheAgendamento(
              agendamento: selecionado,
              aoCancelar: _acaoDeCancelar(selecionado, fecharFolha: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _montarLista() {
    final visiveis = _visiveis;
    final itens = <Widget>[
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextField(
          controller: _busca,
          onChanged: _mudarBusca,
          decoration: const InputDecoration(
            hintText: Textos.buscaDica,
            prefixIcon: Icon(Icons.search),
          ),
        ),
      ),
      _BarraFiltros(filtro: _filtro, aoMudar: _mudarFiltro),
      const SizedBox(height: 8),
    ];
    if (visiveis.isEmpty) {
      itens.add(
        const Aviso(
          icone: Icons.event_busy,
          titulo: Textos.vazioTitulo,
          texto: Textos.vazioTexto,
        ),
      );
    }
    var diaAnterior = '';
    for (final agendamento in visiveis) {
      if (agendamento.dia != diaAnterior) {
        diaAnterior = agendamento.dia;
        itens.add(_TituloDia(texto: agendamento.diaFormatado));
      }
      final selecionado = _selecionado != null && _selecionado!.id == agendamento.id;
      itens.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CartaoAgendamento(
            agendamento: agendamento,
            aoTocar: _abrirDetalhe,
            selecionado: widget.larga && selecionado,
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(Tema.espaco),
          children: itens,
        ),
      ),
    );
  }
}

class _TituloDia extends StatelessWidget {
  final String texto;

  const _TituloDia({required this.texto});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 14, color: esquema.primary),
          const SizedBox(width: 6),
          Text(
            texto,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: esquema.primary,
                  fontWeight: FontWeight.bold,
                ),
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
      'SOLICITADA': 'Solicitadas',
      'AGENDADA': 'Agendadas',
      'CONCLUIDA': 'Concluídas',
      'CANCELADA': 'Canceladas',
      'RECUSADA': 'Recusadas',
    };
    final chips = <Widget>[];
    for (final opcao in opcoes.entries) {
      chips.add(
        ChoiceChip(
          label: Text(opcao.value),
          selected: filtro == opcao.key,
          onSelected: (_) => aoMudar(opcao.key),
        ),
      );
    }
    return Wrap(spacing: 8, runSpacing: 4, children: chips);
  }
}
