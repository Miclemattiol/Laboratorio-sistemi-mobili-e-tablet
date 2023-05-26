import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDocument<T> {
  final DocumentSnapshot firestoreDoc;
  final T data;

  String get id => firestoreDoc.id;
  DocumentReference get reference => firestoreDoc.reference;

  const FirestoreDocument(this.firestoreDoc, this.data);
}

typedef FirestoreConverter<Input, Output> = Iterable<FirestoreDocument<Output>> Function(QuerySnapshot<Input> data);

FirestoreConverter<Input, Output> firestoreConverter<Input, Output>(Output Function(QueryDocumentSnapshot<Input> doc) parseDoc) {
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

Iterable<FirestoreDocument<T>> defaultFirestoreConverter<T>(QuerySnapshot<T> data) => firestoreConverter<T, T>((doc) => doc.data())(data);
