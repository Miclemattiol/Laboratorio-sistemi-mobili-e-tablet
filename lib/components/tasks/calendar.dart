import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/utils.dart';
import 'package:intl/intl.dart';

enum _DateRangeStatus {
  singleDay,
  start,
  between,
  end
}

class Calendar extends StatefulWidget {
  final DateTime? initialDate;
  final List<DateTimeRange> ranges;

  const Calendar(this.ranges, {super.key}) : initialDate = null;

  Calendar.singleTask(DateTimeRange range, {super.key})
      : initialDate = range.start,
        ranges = [
          range
        ];

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  static const _rowHeight = 48.0;
  late DateTime _date = () {
    final initialDate = widget.initialDate ?? DateTime.now();
    return DateTime(initialDate.year, initialDate.month);
  }();

  Color get _headerTextColor => Theme.of(context).colorScheme.onPrimaryContainer;

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

    return dayWidgets.slices(DateTime.daysPerWeek).map((row) => SizedBox(height: _rowHeight, child: Row(children: row))).toList();
  }

  Widget _buildDay(DateTime date) {
    const size = _rowHeight * .66;
    final now = DateTime.now();
    final isToday = date.isSameDayAs(now);

    final rangeStatus = () {
      if (widget.ranges.isEmpty) return null;

      final range = widget.ranges.first; //TODO other ranges
      if (date.isSameDayAs(range.start)) {
        if (date.isSameDayAs(range.end)) {
          return _DateRangeStatus.singleDay;
        }
        return _DateRangeStatus.start;
      }
      if (date.isSameDayAs(range.end)) {
        return _DateRangeStatus.end;
      }
      if (date.isAfter(range.start) && date.isBefore(range.end)) {
        return _DateRangeStatus.between;
      }
      return null;
    }();

    final backgroundColor = () {
      if (rangeStatus != null) return Colors.redAccent; //TODO other ranges
      if (isToday) return Theme.of(context).colorScheme.primary;
      return null;
    }();

    final textColor = () {
      if (backgroundColor != null) return backgroundColor.computeLuminance() < .5 ? Colors.white : Colors.black;
      if (isToday) return Theme.of(context).colorScheme.onPrimary;
      if (date.month != _date.month) return Theme.of(context).disabledColor;
      return null;
    }();

    final borderRadius = () {
      const radius = Radius.circular(size / 2);
      switch (rangeStatus) {
        case _DateRangeStatus.start:
          return const BorderRadius.only(topLeft: radius, bottomLeft: radius);
        case _DateRangeStatus.between:
          return null;
        case _DateRangeStatus.end:
          return const BorderRadius.only(topRight: radius, bottomRight: radius);
        default:
          return BorderRadius.circular(size / 2);
      }
    }();

    return Expanded(
      child: Center(
        child: Container(
          width: (rangeStatus == null || rangeStatus == _DateRangeStatus.singleDay) ? size : double.infinity,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
          ),
          child: Center(
            child: Text("${date.day}", textAlign: TextAlign.center, style: TextStyle(color: textColor)),
          ),
        ),
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
          boxShadow: [
            BoxShadow(color: Theme.of(context).colorScheme.onBackground, spreadRadius: 1)
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                children: [
                  _buildMonthPicker(),
                  _buildWeekNames()
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: Column(children: _buildDays()),
            )
          ],
        ),
      ),
    );
  }
}
