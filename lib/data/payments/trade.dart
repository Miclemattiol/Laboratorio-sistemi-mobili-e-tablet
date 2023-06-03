import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/payment_or_trade.dart';
import 'package:house_wallet/data/user.dart';

class Trade {
  final num amount;
  final String from;
  final String to;
  final DateTime date;
  final String? description;

  static const acceptedKey = "accepted";
  static const amountKey = "amount";
  static const fromKey = "from";
  static const toKey = "to";
  static const dateKey = "date";
  static const descriptionKey = "description";

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
      amount: data[amountKey],
      from: data[fromKey],
      to: data[toKey],
      date: (data[dateKey] as Timestamp).toDate(),
      description: data[descriptionKey],
    );
  }

  static Map<String, dynamic> toFirestore(Trade trade, [SetOptions? _]) {
    return {
      acceptedKey: false,
      amountKey: trade.amount,
      fromKey: trade.from,
      toKey: trade.to,
      dateKey: Timestamp.fromDate(trade.date),
      descriptionKey: trade.description,
    };
  }
}

class TradeRef extends PaymentOrTrade {
  final User to;

  const TradeRef({
    required super.price,
    required super.from,
    required this.to,
    required super.date,
    required super.description,
  });

  @override
  Shares get shares => {to.uid: 1};

  static FirestoreConverter<Trade, TradeRef> converter(BuildContext context) {
    final houseRef = HouseDataRef.of(context);
    return firestoreConverter((doc) {
      final trade = doc.data();
      return TradeRef(
        price: trade.amount,
        from: houseRef.getUser(trade.from),
        to: houseRef.getUser(trade.to),
        date: trade.date,
        description: trade.description,
      );
    });
  }
}
