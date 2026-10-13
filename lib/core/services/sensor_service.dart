import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

enum DeviceOrientationState {
  faceUp,
  faceDown,
  unknown;

  String get label {
    switch (this) {
      case DeviceOrientationState.faceUp:
        return 'Face Up (Screen Up)';
      case DeviceOrientationState.faceDown:
        return 'Face Down (Flipped)';
      case DeviceOrientationState.unknown:
        return 'Tilted / In Hand';
    }
  }
}

class SensorService {
  final _controller = StreamController<DeviceOrientationState>.broadcast();
  Stream<DeviceOrientationState> get orientationStream => _controller.stream;

  DeviceOrientationState _currentStableState = DeviceOrientationState.faceUp;
  DeviceOrientationState get currentStableState => _currentStableState;

  DeviceOrientationState _candidateState = DeviceOrientationState.faceUp;
  DateTime _candidateStateStartTime = DateTime.now();
  StreamSubscription? _subscription;

  static const Duration _stabilityDuration = Duration(milliseconds: 900);
  static const double _zThreshold = 6.5;
  static const double _xyTiltThreshold = 4.5;

  SensorService() {
    _initSensor();
  }

  void _initSensor() {
    try {
      _subscription = accelerometerEventStream().listen(
        _onAccelerometerEvent,
        onError: (err) {
          debugPrint('Accelerometer stream error or unavailable: $err');
        },
      );
    } catch (e) {
      debugPrint('Sensor not supported on this platform: $e');
    }
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final x = event.x;
    final y = event.y;
    final z = event.z;
    final xyMagnitude = sqrt(x * x + y * y);

    DeviceOrientationState rawState = DeviceOrientationState.unknown;

    if (xyMagnitude < _xyTiltThreshold) {
      if (z > _zThreshold) {
        rawState = DeviceOrientationState.faceUp;
      } else if (z < -_zThreshold) {
        rawState = DeviceOrientationState.faceDown;
      }
    }

    final now = DateTime.now();

    if (rawState != _candidateState) {
      _candidateState = rawState;
      _candidateStateStartTime = now;
    } else {
      // If rawState has been stable for _stabilityDuration and differs from currentStableState
      if (now.difference(_candidateStateStartTime) >= _stabilityDuration) {
        if (_candidateState != _currentStableState &&
            _candidateState != DeviceOrientationState.unknown) {
          _currentStableState = _candidateState;
          _controller.add(_currentStableState);
        }
      }
    }
  }

  /// Allows programmatic override or testing on devices/emulators without accelerometer
  void simulateOrientation(DeviceOrientationState state) {
    if (_currentStableState != state) {
      _currentStableState = state;
      _controller.add(state);
    }
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
