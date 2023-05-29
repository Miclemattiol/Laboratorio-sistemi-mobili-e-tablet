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
      title: data["title"],
      from: (data["from"] as Timestamp).toDate(),
      to: (data["to"] as Timestamp).toDate(),
      repeating: data["repeating"] != null ? RepeatOptions.values[data["repeating"]] : null,
      interval: data["interval"],
      description: data["description"],
      assignedTo: Set.from(data["assignedTo"]),
    );
  }

  static Map<String, dynamic> toFirestore(Task trade, [SetOptions? _]) {
    return {
      "title": trade.title,
      "from": Timestamp.fromDate(trade.from),
      "to": Timestamp.fromDate(trade.to),
      "repeating": trade.repeating?.index,
      "interval": trade.interval,
      "description": trade.description,
      "assignedTo": trade.assignedTo,
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
