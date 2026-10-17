// Todos os textos do aplicativo. Trocar aqui muda a cara do app sem mexer nas
// telas.
class Textos {
  static const String nomeClinica = 'UninoVet';
  static const String slogan = 'Cuidando de quem você ama';

  static const String tituloAgendamentos = 'Agendamentos';
  static const String subtituloAgendamentos = 'Acompanhe as consultas da clínica';

  static const String filtroTodos = 'Todos';

  static const String carregando = 'Buscando agendamentos...';
  static const String vazioTitulo = 'Nenhum agendamento';
  static const String vazioTexto = 'Não há consultas para este filtro.';
  static const String erroTitulo = 'Não deu para carregar';
  static const String erroTexto = 'Confira se o painel está no ar e tente de novo.';
  static const String tentarNovamente = 'Tentar de novo';

  static const String detalheTitulo = 'Detalhes da consulta';
  static const String rotuloAnimal = 'Animal';
  static const String rotuloEspecie = 'Espécie';
  static const String rotuloVeterinario = 'Veterinário';
  static const String rotuloData = 'Data e hora';
  static const String rotuloMotivo = 'Motivo';
  static const String rotuloStatus = 'Situação';
  static const String fechar = 'Fechar';

  static String contagem(int quantidade) {
    if (quantidade == 1) {
      return '1 consulta';
    }
    return '$quantidade consultas';
  }
}
