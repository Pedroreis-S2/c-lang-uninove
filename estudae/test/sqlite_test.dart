import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:estudae/config/campos.dart';
import 'package:estudae/dados/sessoes_dao.dart';

// Testa o CRUD no SQLite. Os testes rodam na VM, entao usamos o sqflite ffi
// com um banco em memoria.
void main() {
  late SessoesDao dao;

  setUp(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dao = SessoesDao(arquivo: inMemoryDatabasePath);
  });

  test('cadastra, consulta, edita e exclui', () async {
    await dao.inserir(<String, Object?>{
      Campos.tema: 'Revisar Dart',
      Campos.duracao: 30,
      Campos.observacao: '',
    });
    await dao.inserir(<String, Object?>{
      Campos.tema: 'Praticar Flutter',
      Campos.duracao: 45,
      Campos.observacao: 'Form e validação',
    });

    var sessoes = await dao.listar();
    expect(sessoes.length, 2);

    final id = sessoes.first[Campos.id] as int;
    await dao.atualizar(id, <String, Object?>{
      Campos.tema: 'Revisar Dart',
      Campos.duracao: 40,
      Campos.observacao: '',
    });

    sessoes = await dao.listar();
    final editada = sessoes.firstWhere((sessao) => sessao[Campos.id] == id);
    expect(editada[Campos.duracao], 40);

    await dao.excluir(id);
    sessoes = await dao.listar();
    expect(sessoes.length, 1);
    expect(sessoes.first[Campos.tema], 'Praticar Flutter');
  });
}
