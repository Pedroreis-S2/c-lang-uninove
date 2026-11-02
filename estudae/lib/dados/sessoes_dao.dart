import 'package:path/path.dart' as caminhos;
import 'package:sqflite/sqflite.dart';

import '../config/campos.dart';

// Acesso ao banco SQLite das sessoes de estudo. Guarda uma unica conexao e
// oferece as operacoes de CRUD. Os dados ficam no arquivo sessoes.db e
// sobrevivem a fechar e reabrir o aplicativo.
class SessoesDao {
  static const String _tabela = 'sessoes';

  final String? _arquivo;
  Database? _conexao;

  // Em producao o arquivo fica no proprio aparelho; nos testes passamos um
  // banco em memoria.
  SessoesDao({String? arquivo}) : _arquivo = arquivo;

  Future<Database> _banco() async {
    final conexaoAtual = _conexao;
    if (conexaoAtual != null) {
      return conexaoAtual;
    }
    final caminho = await _caminho();
    final opcoes = OpenDatabaseOptions(version: 1, onCreate: _criarTabela);
    final conexao = await databaseFactory.openDatabase(caminho, options: opcoes);
    _conexao = conexao;
    return conexao;
  }

  Future<String> _caminho() async {
    final arquivo = _arquivo;
    if (arquivo != null) {
      return arquivo;
    }
    final pasta = await databaseFactory.getDatabasesPath();
    return caminhos.join(pasta, 'sessoes.db');
  }

  Future<void> _criarTabela(Database banco, int versao) async {
    await banco.execute(
      'CREATE TABLE $_tabela ('
      '${Campos.id} INTEGER PRIMARY KEY AUTOINCREMENT, '
      '${Campos.tema} TEXT NOT NULL, '
      '${Campos.duracao} INTEGER NOT NULL, '
      '${Campos.observacao} TEXT NOT NULL'
      ')',
    );
  }

  Future<List<Map<String, Object?>>> listar() async {
    final banco = await _banco();
    return banco.query(_tabela, orderBy: '${Campos.id} ASC');
  }

  Future<void> inserir(Map<String, Object?> dados) async {
    final banco = await _banco();
    await banco.insert(_tabela, dados);
  }

  Future<void> atualizar(int id, Map<String, Object?> dados) async {
    final banco = await _banco();
    await banco.update(
      _tabela,
      dados,
      where: '${Campos.id} = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<void> excluir(int id) async {
    final banco = await _banco();
    await banco.delete(
      _tabela,
      where: '${Campos.id} = ?',
      whereArgs: <Object?>[id],
    );
  }
}
