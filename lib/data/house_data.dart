import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/user.dart';

class HouseData {
  final String owner;
  final List<String> users;

  const HouseData({
    required this.owner,
    required this.users,
  });

  factory HouseData.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, [SnapshotOptions? _]) {
    final data = doc.data()!;
    return HouseData(
      owner: data["owner"],
      users: List.from(data["users"]),
    );
  }

  static Map<String, dynamic> toFirestore(HouseData house, [SetOptions? _]) {
    return {
      "owner": house.owner,
      "users": house.users,
    };
  }
}

class HouseDataRef {
  final User owner;
  final Map<String, User> users;

  const HouseDataRef({
    required this.owner,
    required this.users,
  });

  User getUser(String uid) => users[uid] ?? const User.invalid();

  static HouseDataRef? Function(QuerySnapshot<User> data) converter(HouseData? house) {
    return (data) {
      if (house == null) return null;
      final users = Map.fromEntries(defaultFirestoreConverter(data).map((user) => MapEntry(user.id, user.data)));
      return HouseDataRef(
        owner: users[house.owner] ?? const User.invalid(),
        users: Map.fromEntries(house.users.map((uid) => MapEntry(uid, users[uid] ?? const User.invalid()))),
      );
    };
  }
}
