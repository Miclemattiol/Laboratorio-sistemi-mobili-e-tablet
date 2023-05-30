T tryOrDefault<T>(T Function() tryFunc, T defaultValue) {
  try {
    return tryFunc();
  } catch (_) {
    return defaultValue;
  }
}

class Range<T extends Comparable> {
  final T? start;
  final T? end;

  const Range(this.start, this.end);

  bool test(T other) {
    if (start?.compareTo(other) == 1) return false;
    if (end?.compareTo(other) == -1) return false;
    return true;
  }
}

extension BoolExtension on bool {
  int toInt() {
    return this ? 1 : 0;
  }
}
