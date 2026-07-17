import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_chanson_2/providers/curtain_provider.dart';
import 'package:uno_chanson_2/services/local_storage_service.dart';
import 'package:uno_chanson_2/widgets/curtain_control_button.dart';
import 'package:uno_chanson_2/widgets/curtain_overlay.dart';

void main() {
  testWidgets('painted curtains render and toggle fully open', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = CurtainProvider(LocalStorageService());
    provider.finishAnimation(false);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: Scaffold(body: CurtainOverlay())),
      ),
    );
    expect(find.bySemanticsLabel('Left theatre curtain'), findsOneWidget);
    expect(find.bySemanticsLabel('Right theatre curtain'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    await tester.tap(find.byType(CurtainControlButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();
    expect(provider.state, CurtainState.open);
    expect(provider.progress, 1);
    expect(find.text('TAP TO OPEN'), findsNothing);
  });

  testWidgets('rapid toggle reverses and reduced motion finishes quickly', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final provider = CurtainProvider(LocalStorageService());
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(body: CurtainOverlay()),
          ),
        ),
      ),
    );
    provider.close();
    await tester.pump(const Duration(milliseconds: 80));
    provider.open();
    await tester.pump(const Duration(milliseconds: 240));
    await tester.pump();
    expect(provider.state, CurtainState.open);
    expect(provider.progress, closeTo(1, .01));
  });

  testWidgets('fully open curtains do not hit the screen center', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final provider = CurtainProvider(LocalStorageService());
    var taps = 0;
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Center(
                  child: ElevatedButton(
                    onPressed: () => taps++,
                    child: const Text('HOME ACTION'),
                  ),
                ),
                const CurtainOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('HOME ACTION'));
    expect(taps, 1);
  });
}
