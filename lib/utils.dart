import 'dart:math';

import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/main.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

T tryOrDefault<T>(T Function() tryFunc, T defaultValue) {
  try {
    return tryFunc();
  } catch (_) {
    return defaultValue;
  }
}

Future<bool> isNotConnectedToInternet(BuildContext context) async {
  if (await InternetConnectionChecker().connectionStatus == InternetConnectionStatus.disconnected) {
    if (context.mounted) {
      CustomDialog.alert(
        context: context,
        title: localizations(context).internetErrorTitle,
        content: localizations(context).internetErrorContent,
      );
    }
    return true;
  }
  return false;
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

extension NumExtensions on num {
  double roundDecimals(int places) {
    final mod = pow(10, places);
    return (this * mod).round() / mod;
  }
}
