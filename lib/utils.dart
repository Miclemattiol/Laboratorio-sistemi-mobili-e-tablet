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

  Range(
    this.start,
    this.end,
  ) : assert(start == null || end == null || start.compareTo(end) != 1);

  const Range.empty()
      : start = null,
        end = null;

  bool get isEmpty => start == null && end == null;

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

extension NullStringExtension on String? {
  String nullTrim() => (this ?? "").trim();
  String? toNullable() => nullTrim() == "" ? null : this!.trim();

  bool containsCaseUnsensitive(Pattern other, [int startIndex = 0]) {
    if (other is String) {
      other = other.toLowerCase();
    }
    return this?.toLowerCase().contains(other, startIndex) ?? false;
  }
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
}

extension DateTimeExtension on DateTime {
  bool isSameDayAs(DateTime other) => year == other.year && month == other.month && day == other.day;
}
