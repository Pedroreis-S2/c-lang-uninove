// TODOS os textos do aplicativo ficam aqui.
// Para trocar o dominio (de plataforma de aulas para comercio, por exemplo),
// edite este arquivo, o campos.dart (nomes dos campos do registro), o
// regras.dart (limites) e o tema.dart (cores). As telas nao precisam mudar.
class Textos {
  // ---- Marca ---------------------------------------------------------------
  static const String nomeApp = 'Estudaê';
  static const String slogan = 'Seu espaço de estudos';

  // ---- Aula 7: telas fixas --------------------------------------------------
  static const String aula07Nome = 'Telas e navegação';
  static const String saudacao = 'Olá, estudante!';
  static const String perguntaInicio = 'O que você quer consultar?';
  static const String destaqueRotulo = 'Próxima aula';
  static const String destaqueTitulo = 'Computação Móvel';
  static const String destaqueDetalhe = 'Hoje · 19h · Sala 204';
  static const String verDisciplina = 'Ver disciplina';
  static const String verAviso = 'Ver aviso';
  static const String tituloDisciplina = 'Disciplina';
  static const String nomeDisciplina = 'Computação Móvel';
  static const String descricaoDisciplina = 'Construção de interfaces com Flutter';
  static const String professorDisciplina = 'Professor: Felipe';
  static const String diaDisciplina = 'Dia: terça-feira';
  static const String horarioDisciplina = 'Horário: 19h';
  static const String salaDisciplina = 'Sala: 204';
  static const String voltarInicio = 'Voltar ao início';
  static const String tituloAviso = 'Aviso da turma';
  static const String textoAviso = 'Traga seu notebook para a próxima aula.';
  static const String fechar = 'Fechar';

  // ---- Aula 8: estado -------------------------------------------------------
  static const String aula08Nome = 'Estado e contador';
  static const String tituloEstudos = 'Plano de estudos';
  static const String concluirSessao = 'Concluir sessão';
  static const String desfazerSessao = 'Desfazer';
  static const String rotuloNome = 'Seu nome';
  static const String modoFoco = 'Modo foco';
  static const String verResumo = 'Ver resumo';
  static const String tituloResumo = 'Resumo';
  static const String nomePadrao = 'Estudante';
  static const String focoAtivoValor = 'Ativado';
  static const String focoInativoValor = 'Desativado';

  static String sessoesConcluidas(int quantidade) =>
      'Sessões concluídas: $quantidade';
  static String saudacaoNome(String nome) => 'Olá, $nome!';
  static String resumoSessoes(int quantidade) =>
      'Sessões concluídas: $quantidade';
  static String resumoNome(String nome) => 'Nome: $nome';
  static String resumoFoco(String foco) => 'Modo foco: $foco';

  // ---- Aula 9: formulario ---------------------------------------------------
  static const String aula09Nome = 'Formulário e retorno';
  static const String tituloNovo = 'Nova sessão';
  static const String tituloEditar = 'Editar sessão';
  static const String rotuloTema = 'Tema do estudo';
  static const String rotuloObservacao = 'Observação (opcional)';
  static const String confirmar = 'Confirmar sessão';
  static const String cancelar = 'Cancelar';
  static const String semObservacao = 'Sem observação';
  static const String tituloUltima = 'Última sessão';
  static const String nenhumaSessao = 'Nenhuma sessão confirmada.';
  static const String cadastrarSessao = 'Nova sessão';
  static const String erroTemaObrigatorio = 'Informe o tema.';
  static const String erroDuracaoObrigatoria = 'Informe a duração.';

  static String rotuloDuracao(int minimo, int maximo) =>
      'Duração em minutos ($minimo a $maximo)';
  static String erroTemaCurto(int minimo) =>
      'Use pelo menos $minimo caracteres.';
  static String erroDuracaoInvalida(int minimo, int maximo) =>
      'Informe um número inteiro de $minimo a $maximo.';
  // Como o valor numerico do registro aparece nos cartoes.
  static String duracao(int valor) => '$valor minutos';
  static const String sufixoDuracao = 'min';

  // ---- Aula 10: lista -------------------------------------------------------
  static const String aula10Nome = 'Lista em memória';
  static const String tituloLista = 'Minhas sessões';
  static const String vazioTitulo = 'Nenhuma sessão ainda';
  static const String vazioTexto = 'Cadastre sua primeira sessão de estudo.';
  static const String editar = 'Editar';
  static const String excluir = 'Excluir';
  static const String tituloExcluir = 'Excluir sessão?';
  static const String sessaoCadastrada = 'Sessão cadastrada.';
  static const String sessaoAtualizada = 'Sessão atualizada.';
  static const String sessaoRemovida = 'Sessão removida.';

  static String contagemLista(int quantidade) =>
      'Sessões nesta execução: $quantidade';
  static String textoExcluir(String tema) => 'Remover "$tema" da lista?';
}
