import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/utils.dart';
import 'package:provider/provider.dart';

typedef Shares = Map<String, int>;

class UpdateData {
  final SharesData? prevValues;
  final SharesData? newValues;

  const UpdateData({this.prevValues, this.newValues});

  bool get isEmpty => prevValues == null && newValues == null;
}

class SharesData {
  final String from;
  final num price;
  final Shares shares;

  const SharesData({
    required this.from,
    required this.price,
    required this.shares,
  });
}

class HouseData {
  final String owner;
  final Map<String, num> users;
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
      users: Map.from(data[usersKey]),
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
  final Map<String, num> balances;

  const HouseDataRef({
    required this.reference,
    required this.owner,
    required this.users,
    required this.balances,
  });

  static const invalidUsersError = "invalid_users";

  String get id => reference.id;

  User getUser(String uid) => users[uid] ?? const User.invalid();
  num getBalance(String uid) => balances[uid] ?? 0;

  static num calculateImpactForUser(String uid, {required String from, required num price, required Shares shares}) {
    final totalShares = shares.values.reduce((prev, value) => prev + value);
    final pricePerShare = price / totalShares;
    final myShare = shares[uid];

    if (from == uid) {
      if (shares.containsKey(uid)) {
        return pricePerShare * (totalShares - myShare!);
      } else {
        return price;
      }
    } else if (shares.containsKey(uid)) {
      return -pricePerShare * myShare!;
    } else {
      return 0;
    }
  }

  void updateBalances(Transaction transaction, List<UpdateData> updateValues) {
    if (updateValues.isEmpty) return;

    final balancesToUpdate = <String, num>{};

    for (final updateValue in updateValues) {
      final prevValues = updateValue.prevValues;
      if (prevValues != null) {
        for (final user in {prevValues.from, ...prevValues.shares.keys}) {
          balancesToUpdate[user] = (balancesToUpdate[user] ?? 0) - calculateImpactForUser(user, from: prevValues.from, price: prevValues.price, shares: prevValues.shares);
        }
      }

      final newValues = updateValue.newValues;
      if (newValues != null) {
        for (final user in {newValues.from, ...newValues.shares.keys}) {
          balancesToUpdate[user] = (balancesToUpdate[user] ?? 0) + calculateImpactForUser(user, from: newValues.from, price: newValues.price, shares: newValues.shares);
        }
      }
    }

    if (balancesToUpdate.isEmpty || balancesToUpdate.values.every((balance) => balance == 0)) return;

    for (final user in balancesToUpdate.keys) {
      if (getUser(user).isInvalid) throw FirebaseException(plugin: "", code: invalidUsersError);
      balancesToUpdate[user] = (balancesToUpdate[user] ?? 0) + getBalance(user);
    }

    transaction.update(reference, balancesToUpdate.map((key, value) => MapEntry("${HouseData.usersKey}.$key", value)));
  }

  static HouseDataRef? Function(QuerySnapshot<User> data) converter(FirestoreDocument<HouseData>? house) {
    return (data) {
      if (house == null) return null;
      final users = Map.fromEntries(defaultFirestoreConverter(data).map((user) => MapEntry(user.id, user.data)));
      return HouseDataRef(
        reference: house.reference,
        owner: users[house.data.owner] ?? const User.invalid(),
        users: Map.fromEntries(house.data.users.keys.map((uid) => MapEntry(uid, users[uid] ?? const User.invalid()))),
        balances: house.data.users.map((key, value) => MapEntry(key, value.roundDecimals(2))),
      );
    };
  }
}
