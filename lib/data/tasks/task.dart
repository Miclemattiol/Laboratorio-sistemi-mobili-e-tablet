import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/user.dart';

class Task {
  final String title;
  final DateTime from;
  final DateTime to;
  final int repeating;
  final int? interval;
  final String? description;
  final List<String> assignedTo;

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
      repeating: data["repeating"],
      interval: data["interval"] ,
      description: data["description"],
      assignedTo: List.from(data["assignedTo"]),
    );
  }

  static Map<String, dynamic> toFirestore(Task trade, [SetOptions? _]) {
    return {
      "title": trade.title,
      "from": Timestamp.fromDate(trade.from),
      "to": Timestamp.fromDate(trade.to),
      "repeating": trade.repeating,
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
  final int repeating;
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
