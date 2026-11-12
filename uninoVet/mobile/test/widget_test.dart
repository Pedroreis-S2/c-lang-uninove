import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:uninovet/main.dart';

const List<Map<String, dynamic>> agendamentosDeTeste = [
  {
    'id': 1,
    'animal': 'Thor',
    'especie': 'Cachorro',
    'veterinario': 'Dra. Marina Reis',
    'data_hora': '2026-10-20 09:00:00',
    'motivo': 'Vacina anual',
    'status': 'AGENDADA',
  },
  {
    'id': 2,
    'animal': 'Nina',
    'especie': 'Gato',
    'veterinario': 'Dra. Julia Castro',
    'data_hora': '2026-10-19 16:00:00',
    'motivo': 'Retorno de rotina',
    'status': 'CONCLUIDA',
  },
];

Future<http.Response> responderAgendamentos(http.Request requisicao) async {
  final corpo = jsonEncode(agendamentosDeTeste);
  return http.Response(corpo, 200, headers: {'content-type': 'application/json; charset=utf-8'});
}

Future<void> abrirApp(WidgetTester tester) async {
  await http.runWithClient(() async {
    await tester.pumpWidget(const UninoVetApp());
    await tester.pumpAndSettle();
  }, () => MockClient(responderAgendamentos));
}

void main() {
  testWidgets('inicio mostra o nome da clinica e o resumo', (WidgetTester tester) async {
    await abrirApp(tester);

    expect(find.text('UninoVet'), findsOneWidget);
    expect(find.text('Resumo da clínica'), findsOneWidget);
    expect(find.text('Próximas consultas'), findsOneWidget);
    expect(find.text('Thor'), findsOneWidget);
  });

  testWidgets('agenda filtra os agendamentos pela busca', (WidgetTester tester) async {
    await abrirApp(tester);

    await tester.tap(find.text('Agenda'));
    await tester.pumpAndSettle();
    expect(find.text('Thor'), findsOneWidget);
    expect(find.text('Nina'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'nina');
    await tester.pumpAndSettle();

    expect(find.text('Thor'), findsNothing);
    expect(find.text('Nina'), findsOneWidget);
  });

  testWidgets('pets lista os animais atendidos', (WidgetTester tester) async {
    await abrirApp(tester);

    await tester.tap(find.text('Pets'));
    await tester.pumpAndSettle();

    expect(find.text('Pets atendidos'), findsOneWidget);
    expect(find.text('Thor'), findsOneWidget);
    expect(find.text('Nina'), findsOneWidget);
  });
}
