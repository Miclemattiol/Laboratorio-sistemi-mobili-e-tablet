import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/user.dart';
import 'package:provider/provider.dart';

class HouseData {
  final String owner;
  final List<String> users;
  final List<String> codes;

  static const ownerKey = "owner";
  static const usersKey = "users";
  static const codesKey = "codes";

  const HouseData({
    required this.owner,
    required this.users,
    required this.codes,
  });

  factory HouseData.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, [SnapshotOptions? _]) {
    final data = doc.data()!;
    return HouseData(
      owner: data[ownerKey],
      users: List.from(data[usersKey]),
      codes: List.from(data[codesKey]),
    );
  }

  static Map<String, dynamic> toFirestore(HouseData house, [SetOptions? _]) {
    return {
      ownerKey: house.owner,
      usersKey: house.users,
      codesKey: house.codes,
    };
  }
}

class HouseDataRef {
  static HouseDataRef of(BuildContext context, {bool listen = true}) => Provider.of<HouseDataRef>(context, listen: listen);

  final DocumentReference reference;
  final User owner;
  final Map<String, User> users;

  const HouseDataRef({
    required this.reference,
    required this.owner,
    required this.users,
  });

  String get id => reference.id;

  User getUser(String uid) => users[uid] ?? const User.invalid();

  static HouseDataRef? Function(QuerySnapshot<User> data) converter(FirestoreDocument<HouseData>? house) {
    return (data) {
      if (house == null) return null;
      final users = Map.fromEntries(defaultFirestoreConverter(data).map((user) => MapEntry(user.id, user.data)));
      return HouseDataRef(
        reference: house.reference,
        owner: users[house.data.owner] ?? const User.invalid(),
        users: Map.fromEntries(house.data.users.map((uid) => MapEntry(uid, users[uid] ?? const User.invalid()))),
      );
    };
  }
}
