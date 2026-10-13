import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class WakelockService {
  bool _isAwake = false;
  bool get isAwake => _isAwake;

  /// Keeps the screen awake (Mode 2 active study)
  Future<void> enableKeepAwake() async {
    try {
      await WakelockPlus.enable();
      _isAwake = true;
      debugPrint('[Wakelock] Screen awake enabled');
    } catch (e) {
      debugPrint('[Wakelock] Failed to enable wakelock: $e');
    }
  }

  /// Disables wakelock, allowing screen to sleep according to system timeout
  Future<void> disableKeepAwake() async {
    try {
      await WakelockPlus.disable();
      _isAwake = false;
      debugPrint('[Wakelock] Screen awake disabled');
    } catch (e) {
      debugPrint('[Wakelock] Failed to disable wakelock: $e');
    }
  }

  /// Mode 3: Attempt screen off / lock according to platform capabilities.
  /// Standard Android user-space security models restrict programmatic hardware display shutoff
  /// without DeviceAdmin or Accessibility permissions. We release all wake-locks to allow immediate
  /// standard sleep, and log capabilities cleanly without faking full-screen black overlays.
  Future<bool> attemptScreenOff() async {
    try {
      await disableKeepAwake();
      // On platforms where direct system display control requires Device Policy Manager,
      // releasing wakelock ensures the screen dims and sleeps normally.
      return true;
    } catch (e) {
      debugPrint('[Wakelock] attemptScreenOff error: $e');
      return false;
    }
  }
}
