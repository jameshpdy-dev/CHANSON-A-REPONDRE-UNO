import 'package:flutter_test/flutter_test.dart';

import 'package:chanson_a_repondre_uno/app.dart';

void main() {
  testWidgets('renders the application placeholder', (WidgetTester tester) async {
    await tester.pumpWidget(const ChansonARepondreUnoApp());

    expect(find.text('Chanson a Repondre UNO!'), findsOneWidget);
  });
}
