import 'package:flutter_test/flutter_test.dart';

import 'package:chanson_a_repondre_uno/app.dart';

void main() {
  testWidgets('renders accessible poster hotspots', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ChansonARepondreUnoApp());

    expect(find.bySemanticsLabel('Play'), findsOneWidget);
    expect(find.bySemanticsLabel('Settings'), findsOneWidget);
  });
}
