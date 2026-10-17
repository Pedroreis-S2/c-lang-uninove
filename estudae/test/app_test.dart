import 'package:estudae/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _abrirMenu(WidgetTester tester, String titulo) async {
  await tester.pumpWidget(const EstudaeApp());
  final item = find.text(titulo);
  await tester.scrollUntilVisible(item, 200);
  await tester.ensureVisible(item);
  await tester.pumpAndSettle();
  await tester.tap(item);
  await tester.pumpAndSettle();
}

Future<void> _cadastrar(
  WidgetTester tester,
  Finder botao,
  String nome,
  String preco,
) async {
  await tester.tap(botao);
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('campoTema')), nome);
  await tester.enterText(find.byKey(const Key('campoDuracao')), preco);
  await tester.tap(find.byKey(const Key('confirmar')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('aula 7: abre a loja e volta', (WidgetTester tester) async {
    await tester.pumpWidget(const EstudaeApp());
    await tester.tap(find.text('Ver disciplina'));
    await tester.pumpAndSettle();
    expect(find.text('Disciplina'), findsOneWidget);
    await tester.tap(find.text('Voltar ao início'));
    await tester.pumpAndSettle();
    expect(find.text('Ver disciplina'), findsOneWidget);
  });

  testWidgets('aula 8: contador nao fica negativo e vai ao resumo',
      (WidgetTester tester) async {
    await _abrirMenu(tester, 'Plano de estudos');
    await tester.tap(find.byKey(const Key('adicionar')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('adicionar')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('remover')));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('verResumo')));
    await tester.pumpAndSettle();
    expect(find.text('Sessões concluídas: 1'), findsOneWidget);
  });

  testWidgets('aula 9: valida o formulario', (WidgetTester tester) async {
    await _abrirMenu(tester, 'Nova sessão');
    await tester.tap(find.byKey(const Key('cadastrarSessao')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('campoTema')), 'AB');
    await tester.enterText(find.byKey(const Key('campoDuracao')), '0');
    await tester.tap(find.byKey(const Key('confirmar')));
    await tester.pump();
    expect(find.text('Use pelo menos 3 caracteres.'), findsOneWidget);
    expect(find.textContaining('número inteiro'), findsOneWidget);
  });

  testWidgets('aula 10: cadastrar, editar e excluir com confirmacao',
      (WidgetTester tester) async {
    await _abrirMenu(tester, 'Minhas sessões');
    expect(find.byKey(const Key('listaVazia')), findsOneWidget);

    await _cadastrar(
      tester,
      find.byKey(const Key('cadastrarVazio')),
      'Revisar Dart',
      '30',
    );
    await _cadastrar(
      tester,
      find.byKey(const Key('cadastrar')),
      'Praticar Flutter',
      '45',
    );
    expect(find.text('Sessões nesta execução: 2'), findsOneWidget);

    await tester.tap(find.byKey(const Key('editar_1')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('campoDuracao')), '40');
    await tester.tap(find.byKey(const Key('confirmar')));
    await tester.pumpAndSettle();
    expect(find.text('40 minutos'), findsOneWidget);
    expect(find.text('Sessões nesta execução: 2'), findsOneWidget);

    await tester.tap(find.byKey(const Key('excluir_2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cancelarExclusao')));
    await tester.pumpAndSettle();
    expect(find.text('Sessões nesta execução: 2'), findsOneWidget);

    await tester.tap(find.byKey(const Key('excluir_2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmarExclusao')));
    await tester.pumpAndSettle();
    expect(find.text('Sessões nesta execução: 1'), findsOneWidget);
    expect(find.text('Praticar Flutter'), findsNothing);
  });
}
