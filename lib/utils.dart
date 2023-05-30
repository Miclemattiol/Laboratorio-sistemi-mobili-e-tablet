T tryOrDefault<T>(T Function() tryFunc, T defaultValue) {
  try {
    return tryFunc();
  } catch (_) {
    return defaultValue;
  }
}

class NumRange<T extends num> {
  final T? start;
  final T? end;

  const NumRange(this.start, this.end);

  bool test(T other) {
    if (start != null && other < start!) return false;
    if (end != null && other > end!) return false;
    return true;
  }
}

class DateRange {
  final DateTime? start;
  final DateTime? end;

  const DateRange(this.start, this.end);

  bool test(DateTime other) {
    if (start != null && other.isBefore(start!)) return false;
    if (end != null && other.isAfter(end!)) return false;
    return true;
  }
}

extension BoolExtension on bool {
  int toInt() {
    return this ? 1 : 0;
  }
}
