import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/textos.dart';
import '../modelos/agendamento.dart';
import '../modelos/opcoes.dart';
import '../servicos/api.dart';
import 'cartao_agendamento.dart';
import 'avatar_pet.dart';

// Detalhes de uma consulta. Aparece numa folha no celular e num painel ao lado
// da lista na tela larga. O botao de cancelar so aparece quando a API diz que
// da (cliente ate 30 min antes); quem decide e sempre o servidor.
class DetalheAgendamento extends StatelessWidget {
  final Agendamento agendamento;
  final VoidCallback? aoCancelar;

  const DetalheAgendamento({
    super.key,
    required this.agendamento,
    this.aoCancelar,
  });

  @override
  Widget build(BuildContext context) {
    final linhas = <Widget>[
      _linha(context, Textos.rotuloAnimal, agendamento.animal),
      _linha(context, Textos.rotuloEspecie, agendamento.especie),
      _linha(context, Textos.rotuloVeterinario, agendamento.veterinario),
    ];
    if (agendamento.tipoServico.isNotEmpty) {
      linhas.add(_linha(context, Textos.rotuloServicoDetalhe, agendamento.tipoServico));
    }
    linhas.add(_linha(context, Textos.rotuloData, agendamento.dataFormatada));
    linhas.add(_linha(context, Textos.rotuloMotivo, agendamento.motivo));
    if (agendamento.motivoRecusa.isNotEmpty) {
      linhas.add(_linha(context, Textos.rotuloRecusa, agendamento.motivoRecusa));
    }
    if (agendamento.totalDocumentos > 0) {
      linhas.add(const SizedBox(height: 8));
      linhas.add(ListaDocumentos(agendamentoId: agendamento.id));
    }
    final cancelar = aoCancelar;
    if (cancelar != null && agendamento.podeCancelar) {
      linhas.add(const SizedBox(height: 12));
      linhas.add(
        OutlinedButton.icon(
          onPressed: cancelar,
          icon: const Icon(Icons.event_busy),
          label: const Text(Textos.cancelarConsulta),
        ),
      );
      linhas.add(
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            Textos.avisoCancelamento,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }
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
          ...linhas,
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

// Receitas e laudos da consulta. O download abre um link temporario no navegador.
class ListaDocumentos extends StatefulWidget {
  final int agendamentoId;

  const ListaDocumentos({super.key, required this.agendamentoId});

  @override
  State<ListaDocumentos> createState() => _ListaDocumentosState();
}

class _ListaDocumentosState extends State<ListaDocumentos> {
  final Api _api = Api();
  List<Documento> _documentos = <Documento>[];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final documentos = await _api.buscarDocumentos(widget.agendamentoId);
      if (!mounted) {
        return;
      }
      setState(() {
        _documentos = documentos;
      });
    } catch (e) {
      // Sem a lista, a tela segue sem a secao de documentos.
    }
  }

  Future<void> _baixar(Documento documento) async {
    try {
      final endereco = await _api.linkDoDocumento(documento.id);
      await launchUrl(Uri.parse(endereco), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Textos.semConexao)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_documentos.isEmpty) {
      return const SizedBox.shrink();
    }
    final itens = <Widget>[
      Text(
        Textos.documentosTitulo,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    ];
    for (final documento in _documentos) {
      itens.add(
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.description_outlined),
          title: Text(documento.nomeArquivo),
          subtitle: Text(documento.tipo),
          trailing: const Icon(Icons.download),
          onTap: () => _baixar(documento),
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: itens);
  }
}
