import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/ambiente.dart';
import '../modelos/agendamento.dart';
import '../modelos/opcoes.dart';
import 'sessao.dart';

// Erro devolvido pela API (ex.: "Esse horario ja esta ocupado"). A mensagem
// ja vem pronta para mostrar na tela.
class ErroApi implements Exception {
  final int status;
  final String mensagem;

  const ErroApi(this.status, this.mensagem);

  @override
  String toString() => mensagem;
}

// Fala com a API Java da clinica. Depois do login, toda chamada leva o token.
class Api {
  Map<String, String> get _cabecalhos {
    final cabecalhos = <String, String>{};
    final token = Sessao.token;
    if (token != null) {
      cabecalhos['Authorization'] = 'Bearer $token';
    }
    return cabecalhos;
  }

  // Devolve o conteudo ("data") ou lanca ErroApi com a mensagem da API.
  dynamic _conteudo(http.Response resposta) {
    dynamic corpo;
    try {
      corpo = jsonDecode(utf8.decode(resposta.bodyBytes));
    } catch (e) {
      corpo = null;
    }
    if (resposta.statusCode >= 400) {
      var mensagem = 'Erro ${resposta.statusCode}';
      if (corpo is Map<String, dynamic> && corpo['erro'] is String) {
        mensagem = corpo['erro'] as String;
      }
      throw ErroApi(resposta.statusCode, mensagem);
    }
    // Aceita {"data": [...]} (API nova) e a lista pura (formato antigo).
    if (corpo is Map<String, dynamic> && corpo.containsKey('data')) {
      return corpo['data'];
    }
    return corpo;
  }

  List<Map<String, dynamic>> _lista(dynamic conteudo) {
    final itens = <Map<String, dynamic>>[];
    if (conteudo is List<dynamic>) {
      for (final item in conteudo) {
        itens.add(item as Map<String, dynamic>);
      }
    }
    return itens;
  }

  Future<void> entrar(String email, String senha) async {
    final resposta = await http.post(
      Uri.parse(Ambiente.rota('/api/login')),
      body: {'email': email, 'senha': senha},
    );
    _guardarSessao(_conteudo(resposta) as Map<String, dynamic>);
  }

  Future<void> cadastrar({
    required String nome,
    required String telefone,
    required String email,
    required String senha,
  }) async {
    final resposta = await http.post(
      Uri.parse(Ambiente.rota('/api/cadastro')),
      body: {'nome': nome, 'telefone': telefone, 'email': email, 'senha': senha},
    );
    _guardarSessao(_conteudo(resposta) as Map<String, dynamic>);
  }

  void _guardarSessao(Map<String, dynamic> dados) {
    Sessao.token = dados['token'] as String;
    Sessao.usuario = UsuarioLogado.doJson(dados['usuario'] as Map<String, dynamic>);
  }

  Future<void> sair() async {
    try {
      await http.post(Uri.parse(Ambiente.rota('/api/logout')), headers: _cabecalhos);
    } catch (e) {
      // Sem rede, o token expira sozinho no servidor.
    }
    Sessao.sair();
  }

  Future<List<Agendamento>> buscarAgendamentos() async {
    final resposta = await http.get(
      Uri.parse(Ambiente.rota('/api/agendamentos')),
      headers: _cabecalhos,
    );
    final agendamentos = <Agendamento>[];
    for (final item in _lista(_conteudo(resposta))) {
      agendamentos.add(Agendamento.doJson(item));
    }
    return agendamentos;
  }

  Future<List<Pet>> buscarPets() async {
    final resposta = await http.get(
      Uri.parse(Ambiente.rota('/api/pets')),
      headers: _cabecalhos,
    );
    final pets = <Pet>[];
    for (final item in _lista(_conteudo(resposta))) {
      pets.add(Pet.doJson(item));
    }
    return pets;
  }

  Future<void> cadastrarPet({
    required String nome,
    required String especie,
    required String raca,
  }) async {
    final resposta = await http.post(
      Uri.parse(Ambiente.rota('/api/pets')),
      headers: _cabecalhos,
      body: {'nome': nome, 'especie': especie, 'raca': raca},
    );
    _conteudo(resposta);
  }

  Future<List<Servico>> buscarServicos() async {
    final resposta = await http.get(
      Uri.parse(Ambiente.rota('/api/tipos-servico')),
      headers: _cabecalhos,
    );
    final servicos = <Servico>[];
    for (final item in _lista(_conteudo(resposta))) {
      servicos.add(Servico.doJson(item));
    }
    return servicos;
  }

  Future<List<VeterinarioOpcao>> buscarVeterinarios() async {
    final resposta = await http.get(
      Uri.parse(Ambiente.rota('/api/veterinarios')),
      headers: _cabecalhos,
    );
    final veterinarios = <VeterinarioOpcao>[];
    for (final item in _lista(_conteudo(resposta))) {
      veterinarios.add(VeterinarioOpcao.doJson(item));
    }
    return veterinarios;
  }

  // Horarios de inicio livres ("08:00", "08:30"...) para o veterinario no dia.
  Future<List<String>> buscarHorarios({
    required int veterinarioId,
    required int servicoId,
    required String dia,
  }) async {
    final endereco = Ambiente.rota(
      '/api/horarios?veterinario_id=$veterinarioId&tipo_servico_id=$servicoId&data=$dia',
    );
    final resposta = await http.get(Uri.parse(endereco), headers: _cabecalhos);
    final horarios = <String>[];
    final conteudo = _conteudo(resposta);
    if (conteudo is List<dynamic>) {
      for (final horario in conteudo) {
        horarios.add(horario as String);
      }
    }
    return horarios;
  }

  // O pedido nasce SOLICITADA: a clinica ainda precisa aceitar.
  Future<void> solicitar({
    required int animalId,
    required int veterinarioId,
    required int servicoId,
    required String dataHora,
    required String motivo,
  }) async {
    final resposta = await http.post(
      Uri.parse(Ambiente.rota('/api/agendamentos')),
      headers: _cabecalhos,
      body: {
        'animal_id': '$animalId',
        'veterinario_id': '$veterinarioId',
        'tipo_servico_id': '$servicoId',
        'data_hora': dataHora,
        'motivo': motivo,
      },
    );
    _conteudo(resposta);
  }

  Future<void> cancelar(int agendamentoId) async {
    final resposta = await http.post(
      Uri.parse(Ambiente.rota('/api/agendamentos/$agendamentoId/cancelar')),
      headers: _cabecalhos,
    );
    _conteudo(resposta);
  }

  Future<List<Documento>> buscarDocumentos(int agendamentoId) async {
    final resposta = await http.get(
      Uri.parse(Ambiente.rota('/api/agendamentos/$agendamentoId/documentos')),
      headers: _cabecalhos,
    );
    final documentos = <Documento>[];
    for (final item in _lista(_conteudo(resposta))) {
      documentos.add(Documento.doJson(item));
    }
    return documentos;
  }

  // Link temporario (2 minutos) para baixar o documento no navegador.
  Future<String> linkDoDocumento(int documentoId) async {
    final resposta = await http.get(
      Uri.parse(Ambiente.rota('/api/documentos/$documentoId/link')),
      headers: _cabecalhos,
    );
    final dados = _conteudo(resposta) as Map<String, dynamic>;
    return Ambiente.rota(dados['url'] as String);
  }
}
