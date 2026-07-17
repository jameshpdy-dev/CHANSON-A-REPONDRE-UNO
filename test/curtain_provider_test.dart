import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_chanson_2/providers/curtain_provider.dart';
import 'package:uno_chanson_2/services/local_storage_service.dart';

void main() {
  test('default state is fully open', () {
    SharedPreferences.setMockInitialValues({});
    final provider = CurtainProvider(LocalStorageService());
    expect(provider.state, CurtainState.open);
    expect(provider.progress, 1);
  });

  test('toggle and drag completion choose the correct target', () {
    SharedPreferences.setMockInitialValues({});
    final provider = CurtainProvider(LocalStorageService());
    provider.toggle();
    expect(provider.state, CurtainState.closing);
    provider.toggle();
    expect(provider.state, CurtainState.opening);
    provider.setProgress(.3);
    provider.completeDrag(0);
    expect(provider.state, CurtainState.closing);
    provider.setProgress(.7);
    provider.completeDrag(0);
    expect(provider.state, CurtainState.opening);
  });

  test('curtain settings persist after restart', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();
    final first = CurtainProvider(storage);
    await first.setAutoOpen(false);
    await first.setFullScreenGestureEnabled(true);
    await first.setCurtainSoundEnabled(true);
    await first.setPreferredOpenProgress(.9);

    final restored = CurtainProvider(storage);
    await restored.initialize();
    expect(restored.autoOpenCurtainsOnStartup, isFalse);
    expect(restored.fullScreenCurtainGestureEnabled, isTrue);
    expect(restored.curtainSoundEnabled, isTrue);
    expect(restored.preferredOpenProgress, 1);
  });
}
