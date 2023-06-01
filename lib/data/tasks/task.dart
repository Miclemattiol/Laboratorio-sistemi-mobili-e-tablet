import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';

enum RepeatOptions {
  daily,
  weekly,
  monthly,
  yearly,
  custom
}

extension RepeatOptionsValues on RepeatOptions {
  IconData get icon {
    switch (this) {
      case RepeatOptions.daily:
        return Icons.repeat_one;
      case RepeatOptions.weekly:
        return Icons.repeat;
      case RepeatOptions.monthly:
        return Icons.calendar_month_outlined;
      case RepeatOptions.yearly:
        return Icons.calendar_today_outlined;
      case RepeatOptions.custom:
        return Icons.edit_calendar_outlined;
    }
  }

  String label(BuildContext context) {
    switch (this) {
      case RepeatOptions.daily:
        return localizations(context).taskRepeatDaily;
      case RepeatOptions.weekly:
        return localizations(context).taskRepeatWeekly;
      case RepeatOptions.monthly:
        return localizations(context).taskRepeatMonthly;
      case RepeatOptions.yearly:
        return localizations(context).taskRepeatYearly;
      case RepeatOptions.custom:
        return localizations(context).taskRepeatCustom;
    }
  }
}

class Task {
  final String title;
  final DateTime from;
  final DateTime to;
  final RepeatOptions? repeating;
  final int? interval;
  final String? description;
  final Set<String> assignedTo;

  static const titleKey = "title";
  static const fromKey = "from";
  static const toKey = "to";
  static const repeatingKey = "repeating";
  static const intervalKey = "interval";
  static const descriptionKey = "description";
  static const assignedToKey = "assignedTo";

  const Task({
    required this.title,
    required this.from,
    required this.to,
    required this.repeating,
    this.interval,
    required this.description,
    required this.assignedTo,
  });

  factory Task.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, [SnapshotOptions? _]) {
    final data = doc.data()!;
    return Task(
      title: data[titleKey],
      from: (data[fromKey] as Timestamp).toDate(),
      to: (data[toKey] as Timestamp).toDate(),
      repeating: data[repeatingKey] != null ? RepeatOptions.values[data[repeatingKey]] : null,
      interval: data[intervalKey],
      description: data[descriptionKey],
      assignedTo: Set.from(data[assignedToKey]),
    );
  }

  static Map<String, dynamic> toFirestore(Task trade, [SetOptions? _]) {
    return {
      titleKey: trade.title,
      fromKey: Timestamp.fromDate(trade.from),
      toKey: Timestamp.fromDate(trade.to),
      repeatingKey: trade.repeating?.index,
      intervalKey: trade.interval,
      descriptionKey: trade.description,
      assignedToKey: trade.assignedTo,
    };
  }
}

class TaskRef {
  final String title;
  final DateTime from;
  final DateTime to;
  final RepeatOptions? repeating;
  final int? interval;
  final String? description;
  final List<User> assignedTo;

  const TaskRef({
    required this.title,
    required this.from,
    required this.to,
    required this.repeating,
    this.interval,
    required this.description,
    required this.assignedTo,
  });

  DateTimeRange get range => DateTimeRange(start: DateTime(from.year, from.month, from.day), end: DateTime(to.year, to.month, to.day));

  static FirestoreConverter<Task, TaskRef> converter(BuildContext context) {
    final houseRef = HouseDataRef.of(context);
    return firestoreConverter((doc) {
      final task = doc.data();
      return TaskRef(
        title: task.title,
        from: task.from,
        to: task.to,
        interval: task.interval,
        repeating: task.repeating,
        description: task.description,
        assignedTo: task.assignedTo.map((user) => houseRef.getUser(user)).toList(),
      );
    });
  }
}
