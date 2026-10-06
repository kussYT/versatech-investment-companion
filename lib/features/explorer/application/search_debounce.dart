import 'dart:async';

/// Delays a search so each keystroke does not call the repository.
abstract interface class SearchDebounce {
  void schedule(Duration delay, Future<void> Function() action);

  void cancel();
}

class TimerSearchDebounce implements SearchDebounce {
  Timer? _timer;

  @override
  void schedule(Duration delay, Future<void> Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, () {
      unawaited(action());
    });
  }

  @override
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Runs the scheduled action only when [flush] is called.
class ManualSearchDebounce implements SearchDebounce {
  Duration? lastDelay;
  Future<void> Function()? pending;

  @override
  void schedule(Duration delay, Future<void> Function() action) {
    lastDelay = delay;
    pending = action;
  }

  @override
  void cancel() {
    pending = null;
  }

  Future<void> flush() async {
    final action = pending;
    pending = null;
    if (action != null) {
      await action();
    }
  }
}

/// Starts the action immediately. Widget tests use it to avoid real timers.
class ImmediateSearchDebounce implements SearchDebounce {
  @override
  void schedule(Duration delay, Future<void> Function() action) {
    unawaited(action());
  }

  @override
  void cancel() {}
}
