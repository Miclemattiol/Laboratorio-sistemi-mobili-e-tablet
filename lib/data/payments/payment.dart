import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/data/user_share.dart';

class Payment {
  final String category;
  final DateTime date;
  final String? description;
  final String from;
  final String? imageUrl;
  final num price;
  final String title;
  final Map<String, int> to;

  const Payment({
    required this.category,
    required this.date,
    required this.description,
    required this.from,
    required this.imageUrl,
    required this.price,
    required this.title,
    required this.to,
  });

  factory Payment.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, [SnapshotOptions? _]) {
    final data = doc.data()!;
    return Payment(
      category: data["category"],
      date: (data["date"] as Timestamp).toDate(),
      description: data["description"],
      from: data["from"],
      imageUrl: data["imageUrl"],
      price: data["price"],
      title: data["title"],
      to: Map.from(data["to"]),
    );
  }

  static Map<String, dynamic> toFirestore(Payment trade, [SetOptions? _]) {
    return {
      "category": trade.category,
      "date": Timestamp.fromDate(trade.date),
      "description": trade.description,
      "from": trade.from,
      "imageUrl": trade.imageUrl,
      "price": trade.price,
      "title": trade.title,
      "to": trade.to,
    };
  }
}

class PaymentRef {
  final Category? category;
  final DateTime date;
  final String? description;
  final User from;
  final String? imageUrl;
  final num price;
  final String title;
  final Map<String, UserShare> to;

  const PaymentRef({
    required this.category,
    required this.date,
    required this.description,
    required this.from,
    required this.imageUrl,
    required this.price,
    required this.title,
    required this.to,
  });

  static FirestoreConverter<Payment, PaymentRef> converter(BuildContext context, Iterable<FirestoreDocument<Category>>? categories) {
    final houseRef = HouseDataRef.of(context);
    final categoriesMap = Map<String, Category>.fromEntries((categories ?? []).map((category) => MapEntry(category.id, category.data)));
    return firestoreConverter((doc) {
      final payment = doc.data();
      return PaymentRef(
        category: categoriesMap[payment.category],
        date: payment.date,
        description: payment.description,
        from: houseRef.getUser(payment.from),
        imageUrl: payment.imageUrl,
        price: payment.price,
        title: payment.title,
        to: payment.to.map((uid, share) => MapEntry(uid, UserShare(houseRef.getUser(uid), share))),
      );
    });
  }
}
