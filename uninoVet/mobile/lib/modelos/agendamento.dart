// Um agendamento (consulta) como o app recebe da API.
class Agendamento {
  final int id;
  final String animal;
  final String especie;
  final String veterinario;
  final String dataHora;
  final String motivo;
  final String status;
  final String tutor;
  final String tipoServico;
  final String fim;
  final String motivoRecusa;
  final bool podeCancelar;
  final int totalDocumentos;

  const Agendamento({
    required this.id,
    required this.animal,
    required this.especie,
    required this.veterinario,
    required this.dataHora,
    required this.motivo,
    required this.status,
    this.tutor = '',
    this.tipoServico = '',
    this.fim = '',
    this.motivoRecusa = '',
    this.podeCancelar = false,
    this.totalDocumentos = 0,
  });

  factory Agendamento.doJson(Map<String, dynamic> json) {
    return Agendamento(
      id: json['id'] as int,
      animal: json['animal'] as String? ?? '',
      especie: json['especie'] as String? ?? '',
      veterinario: json['veterinario'] as String? ?? '',
      dataHora: json['data_hora'] as String? ?? '',
      motivo: json['motivo'] as String? ?? '',
      status: json['status'] as String? ?? 'AGENDADA',
      tutor: json['tutor'] as String? ?? '',
      tipoServico: json['tipo_servico'] as String? ?? '',
      fim: json['fim'] as String? ?? '',
      motivoRecusa: json['motivo_recusa'] as String? ?? '',
      podeCancelar: _comoBooleano(json['pode_cancelar']),
      totalDocumentos: json['total_documentos'] as int? ?? 0,
    );
  }

  static bool _comoBooleano(dynamic valor) {
    return valor == true || valor == 1;
  }

  // Mostra "20/10/2026 09:00" a partir de "2026-10-20 09:00:00".
  String get dataFormatada {
    final partes = dataHora.split(' ');
    if (partes.length < 2) {
      return dataHora;
    }
    final data = partes[0].split('-');
    final hora = partes[1];
    if (data.length < 3) {
      return dataHora;
    }
    final horaCurta = hora.length >= 5 ? hora.substring(0, 5) : hora;
    return '${data[2]}/${data[1]}/${data[0]} $horaCurta';
  }

  // Dia da consulta como "2026-10-20", usado para agrupar a agenda.
  String get dia {
    final partes = dataHora.split(' ');
    return partes[0];
  }

  // Hora da consulta como "09:00".
  String get hora {
    final partes = dataHora.split(' ');
    if (partes.length < 2) {
      return '';
    }
    final horaCompleta = partes[1];
    if (horaCompleta.length < 5) {
      return horaCompleta;
    }
    return horaCompleta.substring(0, 5);
  }

  // Mostra "20/10/2026" a partir de "2026-10-20".
  String get diaFormatado {
    final data = dia.split('-');
    if (data.length < 3) {
      return dia;
    }
    return '${data[2]}/${data[1]}/${data[0]}';
  }
}
