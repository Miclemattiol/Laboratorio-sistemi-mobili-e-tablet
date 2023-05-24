import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:house_wallet/data/user.dart';

class FirestoreData {
  static DocumentReference<User> userFirestoreRef(String userId) => FirebaseFirestore.instance.doc("/users/$userId").withConverter(fromFirestore: User.fromFirestore, toFirestore: User.toFirestore);

  static final _users = <String, User>{};
  static Future<User> getUser(String uid) async {
    if (!_users.containsKey(uid)) {
      try {
        _users[uid] = (await userFirestoreRef(uid).get()).data()!;
      } catch (_) {}
    }
    return _users[uid] ?? const User.invalid();
  }
}

class FirestoreDocument<T> {
  final DocumentSnapshot firestoreDoc;
  final T data;

  String get id => firestoreDoc.id;
  DocumentReference get reference => firestoreDoc.reference;

  const FirestoreDocument(this.firestoreDoc, this.data);
}

Iterable<FirestoreDocument<T>> defaultFirestoreConverter<T>(QuerySnapshot<T> data) => firestoreConverter<T, T>((doc) => doc.data())(data);

Iterable<FirestoreDocument<Output>> Function(QuerySnapshot<Input> data) firestoreConverter<Input, Output>(Output Function(QueryDocumentSnapshot<Input> doc) parseDoc) {
  return (QuerySnapshot<Input> data) {
    return data.docs.expand((doc) {
      try {
        return [
          FirestoreDocument(doc, parseDoc(doc))
        ];
      } catch (_) {
        return [];
      }
    });
  };
}

Future<Iterable<FirestoreDocument<Output>>> Function(QuerySnapshot<Input> data) firestoreConverterAsync<Input, Output>(Future<Output> Function(QueryDocumentSnapshot<Input> doc) parseDoc) {
  return (QuerySnapshot<Input> data) async {
    final parsed = await Future.wait(data.docs.map((doc) async {
      try {
        return FirestoreDocument(doc, await parseDoc(doc));
      } catch (_) {
        return null;
      }
    }));
    return parsed.whereType<FirestoreDocument<Output>>();
  };
}
