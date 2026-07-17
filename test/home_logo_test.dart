import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chanson_2/widgets/home_header.dart';

void main() {
  testWidgets('Home logo uses contain and preserves image ratio', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeHeader(onProfile: () {}, onSettings: () {}),
        ),
      ),
    );
    await tester.pump();
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.fit, BoxFit.contain);
    expect(
      find.bySemanticsLabel('Chanson à Répondre application logo'),
      findsOneWidget,
    );
    expect(find.text("L’ART DE LA PAROLE PARTAGÉE"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing logo displays compact fallback', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeHeader(
            logoPath: 'assets/images/missing_logo.png',
            onProfile: () {},
            onSettings: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Chanson à Répondre'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
