import 'package:flutter/material.dart';

enum ActivityType {
  shopping,
  trade
}

extension ActivityTypeData on ActivityType {
  IconData get icon {
    switch (this) {
      case ActivityType.shopping:
        return Icons.shopping_basket;
      case ActivityType.trade:
        return Icons.compare_arrows;
    }
  }
}

class Activity {
  final ActivityType type;
  final DateTime date;
  final List<String> details;

  const Activity({
    required this.type,
    required this.date,
    required this.details,
  });
}
