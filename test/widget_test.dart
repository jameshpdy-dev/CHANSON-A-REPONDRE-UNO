import 'package:flutter_test/flutter_test.dart';

import 'package:chanson_a_repondre_uno/app.dart';

void main() {
  testWidgets('renders the home menu', (WidgetTester tester) async {
    await tester.pumpWidget(const ChansonARepondreUnoApp());

    expect(find.text('CHOOSE YOUR PATH'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
