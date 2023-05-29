T tryOrDefault<T>(T Function() tryFunc, T defaultValue) {
  try {
    return tryFunc();
  } catch (_) {
    return defaultValue;
  }
}

extension BoolExtension on bool {
  int toInt() {
    return this ? 1 : 0;
  }
}
