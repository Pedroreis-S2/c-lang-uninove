// Todos os textos do aplicativo. Trocar aqui muda a cara do app sem mexer nas
// telas.
class Textos {
  static const String nomeClinica = 'UninoVet';
  static const String slogan = 'Cuidando de quem você ama';

  static const String tituloAgendamentos = 'Agendamentos';
  static const String subtituloAgendamentos = 'Acompanhe as consultas da clínica';

  static const String filtroTodos = 'Todos';

  static const String menuInicio = 'Início';
  static const String menuAgenda = 'Agenda';
  static const String menuPets = 'Pets';
  static const String atualizar = 'Atualizar';
  static const String temaClaro = 'Modo claro';
  static const String temaEscuro = 'Modo escuro';

  static const String saudacao = 'Olá, equipe UninoVet';
  static const String resumoTitulo = 'Resumo da clínica';
  static const String proximasTitulo = 'Próximas consultas';
  static const String proximasVazio = 'Nenhuma consulta agendada.';
  static const String veterinariosTitulo = 'Consultas por veterinário';
  static const String totalConsultas = 'Total';
  static const String situacaoTitulo = 'Situação das consultas';

  static const String buscaDica = 'Buscar por animal, veterinário ou motivo';
  static const String selecioneConsulta = 'Selecione uma consulta para ver os detalhes';

  static const String petsTitulo = 'Pets atendidos';
  static const String petsSubtitulo = 'Quem já passou pela clínica';
  static const String petsVazio = 'Nenhum pet encontrado.';
  static const String ultimaConsulta = 'Última consulta';

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

  // Login e cadastro
  static const String loginTitulo = 'Entrar';
  static const String loginSubtitulo = 'Acompanhe e solicite consultas do seu pet';
  static const String rotuloEmail = 'E-mail';
  static const String rotuloSenha = 'Senha';
  static const String rotuloNome = 'Seu nome';
  static const String rotuloTelefone = 'Telefone';
  static const String botaoEntrar = 'Entrar';
  static const String botaoCadastrar = 'Criar conta';
  static const String irParaCadastro = 'Ainda não tenho conta';
  static const String irParaLogin = 'Já tenho conta';
  static const String cadastroTitulo = 'Criar conta de tutor';
  static const String sair = 'Sair';
  static const String preenchaTudo = 'Preencha todos os campos.';
  static const String senhaCurta = 'A senha precisa ter pelo menos 6 caracteres.';
  static const String semConexao = 'Não consegui falar com a clínica. Tente de novo.';

  // Solicitar consulta
  static const String solicitarBotao = 'Solicitar';
  static const String solicitarTitulo = 'Solicitar agendamento';
  static const String solicitarAviso =
      'O pedido não reserva o horário: a clínica precisa aceitar. Você acompanha pelo status.';
  static const String rotuloPet = 'Pet';
  static const String rotuloServico = 'Serviço';
  static const String rotuloDia = 'Dia';
  static const String rotuloHorario = 'Horário';
  static const String escolhaDia = 'Escolher o dia';
  static const String semHorarios = 'Sem horários livres neste dia.';
  static const String enviarPedido = 'Enviar pedido';
  static const String pedidoEnviado = 'Pedido enviado! Aguarde a resposta da clínica.';
  static const String cadastreUmPet = 'Cadastre um pet antes de solicitar.';

  // Cancelar e documentos
  static const String cancelarConsulta = 'Cancelar consulta';
  static const String confirmarCancelar = 'Cancelar esta consulta?';
  static const String consultaCancelada = 'Consulta cancelada.';
  static const String naoCancelar = 'Voltar';
  static const String avisoCancelamento =
      'O cancelamento pelo app vale até 30 minutos antes. Depois disso, ligue para a clínica.';
  static const String documentosTitulo = 'Documentos';
  static const String rotuloServicoDetalhe = 'Serviço';
  static const String rotuloRecusa = 'Motivo da recusa';

  // Pets
  static const String novoPet = 'Novo pet';
  static const String rotuloNomePet = 'Nome do pet';
  static const String rotuloEspeciePet = 'Espécie (Cachorro, Gato...)';
  static const String rotuloRacaPet = 'Raça (opcional)';
  static const String salvar = 'Salvar';
  static const String petCadastrado = 'Pet cadastrado!';

  static String contagem(int quantidade) {
    if (quantidade == 1) {
      return '1 consulta';
    }
    return '$quantidade consultas';
  }
}
