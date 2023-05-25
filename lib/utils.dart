T tryOrDefault<T>(T Function() tryFunc, T defaultValue) {
  try {
    return tryFunc();
  } catch (_) {
    return defaultValue;
  }
}
