import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/providers.dart';
import '../../../../core/services/sensor_service.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../study_mode/domain/study_mode.dart';
import '../../domain/entities/study_session.dart';
import 'study_session_controller.dart';

enum TimerStatus { stopped, running, paused }

class StopwatchState {
  final TimerStatus status;
  final DateTime? sessionStartTime;
  final int accumulatedSeconds;
  final int elapsedSeconds;
  final String? activeSessionId;
  final StudyMode mode;
  final DeviceOrientationState currentOrientation;

  const StopwatchState({
    this.status = TimerStatus.stopped,
    this.sessionStartTime,
    this.accumulatedSeconds = 0,
    this.elapsedSeconds = 0,
    this.activeSessionId,
    this.mode = StudyMode.manual,
    this.currentOrientation = DeviceOrientationState.faceUp,
  });

  bool get isRunning => status == TimerStatus.running;
  bool get isPaused => status == TimerStatus.paused;
  bool get isStopped => status == TimerStatus.stopped;

  StopwatchState copyWith({
    TimerStatus? status,
    DateTime? sessionStartTime,
    int? accumulatedSeconds,
    int? elapsedSeconds,
    String? activeSessionId,
    StudyMode? mode,
    DeviceOrientationState? currentOrientation,
  }) {
    return StopwatchState(
      status: status ?? this.status,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      accumulatedSeconds: accumulatedSeconds ?? this.accumulatedSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      activeSessionId: activeSessionId ?? this.activeSessionId,
      mode: mode ?? this.mode,
      currentOrientation: currentOrientation ?? this.currentOrientation,
    );
  }
}

class StopwatchNotifier extends Notifier<StopwatchState> {
  final Uuid _uuid = const Uuid();
  Timer? _ticker;
  StreamSubscription<DeviceOrientationState>? _sensorSubscription;
  DateTime? _initialSessionCreatedTime;

  @override
  StopwatchState build() {
    final settings = ref.watch(settingsControllerProvider);
    final sensorService = ref.watch(sensorServiceProvider);

    _sensorSubscription?.cancel();
    _sensorSubscription = sensorService.orientationStream.listen((orientation) {
      _handleOrientationChanged(orientation);
    });

    ref.onDispose(() {
      _ticker?.cancel();
      _sensorSubscription?.cancel();
      ref.read(wakelockServiceProvider).disableKeepAwake();
    });

    return StopwatchState(
      mode: settings.studyMode,
      currentOrientation: sensorService.currentStableState,
    );
  }

  void _handleOrientationChanged(DeviceOrientationState orientation) {
    state = state.copyWith(currentOrientation: orientation);

    if (state.mode == StudyMode.faceUpOnFaceDownOff) {
      // Screen UP = ON, Screen DOWN = OFF
      if (orientation == DeviceOrientationState.faceUp) {
        if (!state.isRunning) {
          if (state.isPaused) {
            resumeTimer();
          } else if (state.isStopped) {
            startTimer();
          }
        }
      } else if (orientation == DeviceOrientationState.faceDown) {
        if (state.isRunning) {
          pauseTimer();
        }
      }
    } else if (state.mode == StudyMode.flipToOnScreenOff) {
      // Screen DOWN = ON, Screen UP = OFF
      if (orientation == DeviceOrientationState.faceDown) {
        if (!state.isRunning) {
          if (state.isPaused) {
            resumeTimer();
          } else if (state.isStopped) {
            startTimer();
          }
        }
      } else if (orientation == DeviceOrientationState.faceUp) {
        if (state.isRunning) {
          pauseTimer();
        }
      }
    }
  }

  void updateMode(StudyMode newMode) {
    if (state.mode == newMode) return;
    state = state.copyWith(mode: newMode);
    if (state.isRunning) {
      _applyWakelockPolicy(newMode);
    }
  }

  void startTimer() {
    if (state.isRunning) return;

    final now = DateTime.now();
    final sessionId = _uuid.v4();
    _initialSessionCreatedTime = now;

    state = state.copyWith(
      status: TimerStatus.running,
      sessionStartTime: now,
      accumulatedSeconds: 0,
      elapsedSeconds: 0,
      activeSessionId: sessionId,
    );

    _applyWakelockPolicy(state.mode);
    _startPeriodicTicker();
  }

  void pauseTimer() {
    if (!state.isRunning) return;

    _ticker?.cancel();
    final now = DateTime.now();
    final currentRunDuration = state.sessionStartTime != null
        ? now.difference(state.sessionStartTime!).inSeconds
        : 0;
    final totalElapsed = state.accumulatedSeconds + currentRunDuration;

    state = state.copyWith(
      status: TimerStatus.paused,
      accumulatedSeconds: totalElapsed,
      elapsedSeconds: totalElapsed,
      sessionStartTime: null,
    );

    ref.read(wakelockServiceProvider).disableKeepAwake();
  }

  void resumeTimer() {
    if (state.isRunning) return;

    final now = DateTime.now();
    state = state.copyWith(
      status: TimerStatus.running,
      sessionStartTime: now,
    );

    _applyWakelockPolicy(state.mode);
    _startPeriodicTicker();
  }

  Future<void> stopTimer() async {
    if (state.isStopped) return;

    _ticker?.cancel();
    ref.read(wakelockServiceProvider).disableKeepAwake();

    final now = DateTime.now();
    int finalDuration = state.accumulatedSeconds;
    if (state.isRunning && state.sessionStartTime != null) {
      finalDuration += now.difference(state.sessionStartTime!).inSeconds;
    }

    final startTime = _initialSessionCreatedTime ?? now.subtract(Duration(seconds: finalDuration));

    // Save session if elapsed time is at least 3 seconds
    if (finalDuration >= 3) {
      final session = StudySession(
        id: state.activeSessionId ?? _uuid.v4(),
        startTime: startTime,
        endTime: now,
        durationSeconds: finalDuration,
        mode: state.mode,
        syncStatus: SyncStatus.local,
        createdAt: startTime,
        updatedAt: now,
      );
      await ref.read(studySessionControllerProvider.notifier).addSession(session);
    }

    state = state.copyWith(
      status: TimerStatus.stopped,
      sessionStartTime: null,
      accumulatedSeconds: 0,
      elapsedSeconds: 0,
      activeSessionId: null,
    );
    _initialSessionCreatedTime = null;
  }

  void _startPeriodicTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.sessionStartTime != null) {
        final currentRunDuration =
            DateTime.now().difference(state.sessionStartTime!).inSeconds;
        final total = state.accumulatedSeconds + currentRunDuration;
        state = state.copyWith(elapsedSeconds: total);
      }
    });
  }

  void _applyWakelockPolicy(StudyMode mode) {
    final wakelock = ref.read(wakelockServiceProvider);
    if (mode == StudyMode.faceUpOnFaceDownOff) {
      wakelock.enableKeepAwake();
    } else if (mode == StudyMode.flipToOnScreenOff) {
      wakelock.attemptScreenOff();
    } else {
      wakelock.disableKeepAwake();
    }
  }

  void simulateOrientation(DeviceOrientationState orientation) {
    ref.read(sensorServiceProvider).simulateOrientation(orientation);
  }
}

final stopwatchControllerProvider =
    NotifierProvider<StopwatchNotifier, StopwatchState>(StopwatchNotifier.new);

typedef StopwatchController = StopwatchNotifier;
