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
    await tester.pumpWidget(const ChansonUnoApp());

    expect(find.text('CHOOSE YOUR PATH'), findsOneWidget);
    for (final label in <String>[
      'Play',
      'Choose Deck',
      'Browse Cards',
      'Search',
      'Journal',
      'AI Chat',
      'Rules',
      'Settings',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });
}
