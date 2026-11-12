// Pet cadastrado pelo tutor.
class Pet {
  final int id;
  final String nome;
  final String especie;
  final String raca;

  const Pet({
    required this.id,
    required this.nome,
    required this.especie,
    required this.raca,
  });

  factory Pet.doJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as int,
      nome: json['nome'] as String? ?? '',
      especie: json['especie'] as String? ?? '',
      raca: json['raca'] as String? ?? '',
    );
  }
}

// Servico que a clinica oferece (consulta, vacina, banho e tosa...).
class Servico {
  final int id;
  final String nome;
  final String categoria;
  final int duracaoMinutos;

  const Servico({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.duracaoMinutos,
  });

  factory Servico.doJson(Map<String, dynamic> json) {
    return Servico(
      id: json['id'] as int,
      nome: json['nome'] as String? ?? '',
      categoria: json['categoria'] as String? ?? '',
      duracaoMinutos: json['duracao_minutos'] as int? ?? 30,
    );
  }
}

class VeterinarioOpcao {
  final int id;
  final String nome;
  final String especialidade;

  const VeterinarioOpcao({
    required this.id,
    required this.nome,
    required this.especialidade,
  });

  factory VeterinarioOpcao.doJson(Map<String, dynamic> json) {
    return VeterinarioOpcao(
      id: json['id'] as int,
      nome: json['nome'] as String? ?? '',
      especialidade: json['especialidade'] as String? ?? '',
    );
  }
}

// Receita, laudo ou outro arquivo anexado a uma consulta.
class Documento {
  final int id;
  final String tipo;
  final String nomeArquivo;

  const Documento({
    required this.id,
    required this.tipo,
    required this.nomeArquivo,
  });

  factory Documento.doJson(Map<String, dynamic> json) {
    return Documento(
      id: json['id'] as int,
      tipo: json['tipo'] as String? ?? '',
      nomeArquivo: json['nome_arquivo'] as String? ?? '',
    );
  }
}
