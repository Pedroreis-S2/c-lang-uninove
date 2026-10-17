// Um agendamento (consulta) como o app recebe da API.
class Agendamento {
  final int id;
  final String animal;
  final String especie;
  final String veterinario;
  final String dataHora;
  final String motivo;
  final String status;

  const Agendamento({
    required this.id,
    required this.animal,
    required this.especie,
    required this.veterinario,
    required this.dataHora,
    required this.motivo,
    required this.status,
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
    );
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
}
