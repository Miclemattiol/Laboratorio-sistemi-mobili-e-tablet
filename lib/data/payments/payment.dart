import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/payment_or_trade.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/data/user_share.dart';
import 'package:provider/provider.dart';

class Payment {
  final String? category;
  final DateTime date;
  final String? description;
  final String from;
  final String? imageUrl;
  final num price;
  final String title;
  final Shares to;

  static const categoryKey = "category";
  static const dateKey = "date";
  static const descriptionKey = "description";
  static const fromKey = "from";
  static const imageUrlKey = "imageUrl";
  static const priceKey = "price";
  static const titleKey = "title";
  static const toKey = "to";

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
      category: data[categoryKey],
      date: (data[dateKey] as Timestamp).toDate(),
      description: data[descriptionKey],
      from: data[fromKey],
      imageUrl: data[imageUrlKey],
      price: data[priceKey],
      title: data[titleKey],
      to: Map.from(data[toKey]),
    );
  }

  static Map<String, dynamic> toFirestore(Payment trade, [SetOptions? _]) {
    return {
      categoryKey: trade.category,
      dateKey: Timestamp.fromDate(trade.date),
      descriptionKey: trade.description,
      fromKey: trade.from,
      imageUrlKey: trade.imageUrl,
      priceKey: trade.price,
      titleKey: trade.title,
      toKey: trade.to,
    };
  }
}

class PaymentRef extends PaymentOrTrade {
  final FirestoreDocument<Category>? category;
  final String? imageUrl;
  final String title;
  final Map<String, UserShare> to;

  const PaymentRef({
    required this.category,
    required super.date,
    required super.description,
    required super.from,
    required this.imageUrl,
    required super.price,
    required this.title,
    required this.to,
  });

  @override
  Shares get shares => to.map((key, value) => MapEntry(key, value.share));

  static FirestoreConverter<Payment, PaymentRef> converter(BuildContext context) {
    final houseRef = HouseDataRef.of(context);
    return firestoreConverter((doc) {
      final categoriesMap = Map.fromEntries((Provider.of<Categories?>(context, listen: false) ?? []).map((category) => MapEntry(category.id, category)));
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
