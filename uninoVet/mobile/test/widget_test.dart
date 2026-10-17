import 'package:flutter_test/flutter_test.dart';

import 'package:uninovet/main.dart';

void main() {
  testWidgets('abre o app mostrando o nome da clinica', (WidgetTester tester) async {
    await tester.pumpWidget(const UninoVetApp());
    await tester.pump();

    expect(find.text('UninoVet'), findsOneWidget);
  });
}
