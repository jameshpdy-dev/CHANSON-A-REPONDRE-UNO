import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../services/local_storage_service.dart';

enum CurtainState { closed, opening, open, closing }

class CurtainProvider extends ChangeNotifier {
  CurtainProvider(this._storage);
  final LocalStorageService _storage;
  static const _key = 'curtain_settings';

  CurtainState state = CurtainState.open;
  double progress = 1;
  bool autoOpenCurtainsOnStartup = true;
  bool fullScreenCurtainGestureEnabled = false;
  bool curtainSoundEnabled = false;
  double preferredOpenProgress = 1;
  bool initialized = false;

  bool get isClosed => progress <= .01;
  bool get isOpen => progress >= .99;
  bool get isAnimating =>
      state == CurtainState.opening || state == CurtainState.closing;

  Future<void> initialize() async {
    try {
      final source = await _storage.read(_key);
      if (source != null) {
        final map = jsonDecode(source) as Map<String, dynamic>;
        autoOpenCurtainsOnStartup = map['autoOpen'] as bool? ?? true;
        fullScreenCurtainGestureEnabled =
            map['fullScreenGesture'] as bool? ?? false;
        curtainSoundEnabled = map['sound'] as bool? ?? false;
        // Older versions allowed partially-open terminal states. Always migrate
        // those values to fully open so curtains cannot cover the interface.
        preferredOpenProgress = 1;
      }
    } on Object {
      // Corrupt preferences safely fall back to defaults.
    }
    initialized = true;
    if (autoOpenCurtainsOnStartup) {
      progress = 0;
      state = CurtainState.closed;
      notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (initialized) open();
    } else {
      progress = 1;
      state = CurtainState.open;
      notifyListeners();
    }
  }

  void open() {
    state = CurtainState.opening;
    notifyListeners();
  }

  void close() {
    state = CurtainState.closing;
    notifyListeners();
  }

  void toggle() {
    if (state == CurtainState.opening) {
      close();
    } else if (state == CurtainState.closing) {
      open();
    } else if (progress >= .5) {
      close();
    } else {
      open();
    }
  }

  void setProgress(double value) {
    progress = value.clamp(0, 1);
    notifyListeners();
  }

  void finishAnimation(bool opened) {
    progress = opened ? 1 : 0;
    state = opened ? CurtainState.open : CurtainState.closed;
    notifyListeners();
  }

  void completeDrag(double velocity) {
    if (velocity.abs() > 500) {
      velocity > 0 ? open() : close();
    } else {
      progress >= .5 ? open() : close();
    }
  }

  Future<void> setAutoOpen(bool value) async {
    autoOpenCurtainsOnStartup = value;
    await _persist();
  }

  Future<void> setFullScreenGestureEnabled(bool value) async {
    fullScreenCurtainGestureEnabled = value;
    await _persist();
  }

  Future<void> setCurtainSoundEnabled(bool value) async {
    curtainSoundEnabled = value;
    await _persist();
  }

  Future<void> setPreferredOpenProgress(double value) async {
    preferredOpenProgress = 1;
    if (state == CurtainState.open) progress = 1;
    await _persist();
  }

  Future<void> _persist() async {
    await _storage.write(_key, {
      'autoOpen': autoOpenCurtainsOnStartup,
      'fullScreenGesture': fullScreenCurtainGestureEnabled,
      'sound': curtainSoundEnabled,
      'openProgress': preferredOpenProgress,
    });
    notifyListeners();
  }

  @override
  void dispose() {
    initialized = false;
    super.dispose();
  }
}
