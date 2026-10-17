import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/ambiente.dart';
import '../modelos/agendamento.dart';

// Fala com o painel Java para buscar os agendamentos.
class Api {
  Future<List<Agendamento>> buscarAgendamentos() async {
    final endereco = Uri.parse(Ambiente.agendamentos);
    final resposta = await http.get(endereco);
    if (resposta.statusCode != 200) {
      throw Exception('Status ${resposta.statusCode}');
    }
    final lista = jsonDecode(resposta.body) as List<dynamic>;
    final agendamentos = <Agendamento>[];
    for (final item in lista) {
      final agendamento = Agendamento.doJson(item as Map<String, dynamic>);
      agendamentos.add(agendamento);
    }
    return agendamentos;
  }
}
