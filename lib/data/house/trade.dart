import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/user.dart';
import 'package:provider/provider.dart';

class Trade {
  final num amount;
  final String from;
  final String to;
  final DateTime date;
  final String? description;

  const Trade({
    required this.amount,
    required this.from,
    required this.to,
    required this.date,
    required this.description,
  });

  factory Trade.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, [SnapshotOptions? _]) {
    final data = doc.data()!;
    return Trade(
      amount: data["amount"],
      from: data["from"],
      to: data["to"],
      date: (data["date"] as Timestamp).toDate(),
      description: data["description"],
    );
  }

  static Map<String, dynamic> toFirestore(Trade trade, [SetOptions? _]) {
    return {
      "accepted": false,
      "amount": trade.amount,
      "from": trade.from,
      "to": trade.to,
      "date": trade.date,
      "description": trade.description,
    };
  }
}

class TradeRef {
  final num amount;
  final User from;
  final User to;
  final DateTime date;
  final String? description;

  const TradeRef({
    required this.amount,
    required this.from,
    required this.to,
    required this.date,
    required this.description,
  });

  static FirestoreConverter<Trade, TradeRef> converter(BuildContext context) {
    final houseRef = Provider.of<HouseDataRef>(context);
    return firestoreConverter((doc) {
      final trade = doc.data();
      return TradeRef(
        amount: trade.amount,
        from: houseRef.getUser(trade.from),
        to: houseRef.getUser(trade.to),
        date: trade.date,
        description: trade.description,
      );
    });
  }
}
