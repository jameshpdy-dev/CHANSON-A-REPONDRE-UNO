// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:uno_chanson_2/app.dart';

void main() {
  testWidgets('home screen displays every navigation option', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ChansonUnoApp(aiBackendUrlOverride: 'https://api.test'),
    );

    expect(find.text('OPEN CURTAINS'), findsOneWidget);
    await tester.tap(find.text('OPEN CURTAINS'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pump();

    expect(
      find.bySemanticsLabel('Chanson à Répondre application logo'),
      findsOneWidget,
    );
    expect(find.text('CHANSON À RÉPONDRE'), findsNothing);
    for (final label in <String>[
      'PLAY',
      'CHOOSE DECK',
      'BROWSE CARDS',
      'SEARCH',
      'JOURNAL',
      'AI CHAT',
      'RULES',
      'SETTINGS',
    ]) {
      expect(find.text(label), label == 'PLAY' ? findsWidgets : findsOneWidget);
    }
  });
}
