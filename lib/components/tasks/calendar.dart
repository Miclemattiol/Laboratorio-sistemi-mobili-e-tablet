import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/data/tasks/task.dart';
import 'package:house_wallet/utils.dart';
import 'package:intl/intl.dart';

enum _RangeStatus { singleDay, start, between, end }

class _RangeColor {
  final Color color;
  final DateTimeRange range;

  DateTime get start => range.start;
  DateTime get end => range.end;

  bool containsDate(DateTime other) => !(other.isBefore(start) || other.isAfter(end));

  const _RangeColor(this.color, this.range);
}

//TODO show repeating tasks
class Calendar extends StatefulWidget {
  final DateTime? initialDate;
  final List<DateTimeRange> ranges;

  const Calendar(this.ranges, {super.key}) : initialDate = null;

  Calendar.singleTask(TaskRef task, {super.key})
      : initialDate = task.repeating == null ? task.range.start : null,
        ranges = [task.range];

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  static const _rowHeight = 48.0;
  static const _todaySize = _rowHeight * .66;
  static const _rangeSize = _rowHeight / 7;
  static const _weeksSeparator = _rowHeight / 3;

  late DateTime _date = () {
    final initialDate = widget.initialDate ?? DateTime.now();
    return DateTime(initialDate.year, initialDate.month);
  }();

  Color get _headerTextColor => Theme.of(context).colorScheme.onPrimary;

  List<List<_RangeColor>> _calculateRanges() {
    if (widget.ranges.isEmpty) return [];

    const colors = [Colors.redAccent, Colors.greenAccent, Colors.blueAccent, Colors.yellowAccent];
    final parsedRanges = <List<_RangeColor>>[];
    final sortedRanges = List<DateTimeRange>.from(widget.ranges)
      ..sort((a, b) {
        final startCompare = a.start.compareTo(b.start);
        return startCompare != 0 ? startCompare : a.end.compareTo(b.end);
      });

    int currentColorIndex = -1;
    Color nextColor([bool restart = false]) => colors[currentColorIndex = restart ? 0 : ((currentColorIndex + 1) % colors.length)];

    List<_RangeColor> currentRange = [_RangeColor(nextColor(), sortedRanges.removeAt(0))];
    DateTime maxEnd = currentRange.first.end;
    for (final range in sortedRanges) {
      if (range.start.isAfter(maxEnd)) {
        parsedRanges.add(currentRange);
        currentRange = [_RangeColor(nextColor(true), range)];
      } else {
        currentRange.add(_RangeColor(nextColor(), range));
        if (range.end.isAfter(maxEnd)) {
          maxEnd = range.end;
        }
      }
    }
    parsedRanges.add(currentRange);

    return parsedRanges;
  }

  List<_RangeColor> _rangesOfDate(DateTime date) {
    for (final ranges in _calculateRanges()) {
      if (!date.isBefore(ranges.first.start)) {
        for (final range in ranges) {
          if (!date.isAfter(range.end)) {
            return ranges;
          }
        }
      }
    }
    return [];
  }

  Widget _buildMonthPicker() {
    final dateFormat = DateFormat("MMMM yyyy", Localizations.localeOf(context).languageCode);

    return SizedBox(
      height: _rowHeight,
      child: Row(
        children: [
          IconButton(
            onPressed: () => setState(() => _date = DateTime(_date.year, _date.month - 1)),
            tooltip: dateFormat.format(DateTime(_date.year, _date.month - 1)).capitalize(),
            icon: Icon(Icons.keyboard_arrow_left, color: _headerTextColor),
          ),
          Expanded(
            child: Text(
              dateFormat.format(_date).capitalize(),
              textAlign: TextAlign.center,
              style: TextStyle(color: _headerTextColor),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _date = DateTime(_date.year, _date.month + 1)),
            tooltip: dateFormat.format(DateTime(_date.year, _date.month + 1)).capitalize(),
            icon: Icon(Icons.keyboard_arrow_right, color: _headerTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekNames() {
    final weekDays = () {
      final weekdays = List<String>.from(DateFormat.EEEE(Localizations.localeOf(context).languageCode).dateSymbols.SHORTWEEKDAYS);
      return weekdays..add(weekdays.removeAt(0));
    }();

    return SizedBox(
      height: _rowHeight,
      child: Row(
        children: weekDays.map((weekday) {
          return Expanded(
            child: Text(
              weekday.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(color: _headerTextColor),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildDays() {
    int totalMonths(DateTime date) => date.year * DateTime.monthsPerYear + date.month;

    final dayWidgets = <Widget>[];
    DateTime date = DateTime(_date.year, _date.month, _date.day - (_date.weekday - DateTime.monday));

    while (totalMonths(date) <= totalMonths(_date) || date.weekday != DateTime.monday) {
      dayWidgets.add(_buildDay(date));
      date = DateTime(date.year, date.month, date.day + 1);
    }

    return dayWidgets.slices(DateTime.daysPerWeek).map((row) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: row)).toList();
  }

  Widget _buildDay(DateTime date) {
    final now = DateTime.now();
    final isToday = date.isSameDayAs(now);
    final rangesOfDate = _rangesOfDate(date);

    _RangeStatus? rangeStatus(_RangeColor range) {
      if (date.isSameDayAs(range.start)) {
        if (date.isSameDayAs(range.end)) {
          return _RangeStatus.singleDay;
        }
        return _RangeStatus.start;
      }
      if (date.isSameDayAs(range.end)) {
        return _RangeStatus.end;
      }
      if (date.isAfter(range.start) && date.isBefore(range.end)) {
        return _RangeStatus.between;
      }
      return null;
    }

    BorderRadiusGeometry? borderRadius(_RangeColor range, _RangeStatus? rangeStatus) {
      const radius = Radius.circular(_rangeSize / 2);
      switch (rangeStatus) {
        case _RangeStatus.start:
          return const BorderRadius.only(topLeft: radius, bottomLeft: radius);
        case _RangeStatus.between:
          return null;
        case _RangeStatus.end:
          return const BorderRadius.only(topRight: radius, bottomRight: radius);
        default:
          return const BorderRadius.all(radius);
      }
    }

    final textColor = () {
      if (isToday) return Theme.of(context).colorScheme.onPrimaryContainer;
      if (date.month != _date.month) return Theme.of(context).disabledColor;
      return null;
    }();

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: _rangeSize / 2),
            child: Container(
              width: _todaySize,
              height: _todaySize,
              decoration: BoxDecoration(
                color: isToday ? Theme.of(context).colorScheme.primaryContainer : null,
                borderRadius: BorderRadius.circular(_todaySize / 2),
              ),
              child: Center(child: Text("${date.day}", textAlign: TextAlign.center, style: TextStyle(color: textColor))),
            ),
          ),
          ...rangesOfDate.map(
            (range) {
              final thisRangeStatus = rangeStatus(range);
              return Container(
                height: _rangeSize,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: range.containsDate(date) ? range.color : Colors.transparent,
                  borderRadius: borderRadius(range, thisRangeStatus),
                ),
              );
            },
          ),
          const SizedHeight(_weeksSeparator)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.background,
          boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.onBackground, spreadRadius: 1)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Theme.of(context).colorScheme.primary,
              child: Column(
                children: [
                  _buildMonthPicker(),
                  _buildWeekNames(),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  const SizedHeight(_weeksSeparator),
                  ..._buildDays(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
