import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreDocument<T> {
  final QueryDocumentSnapshot<T> firestoreDoc;
  final T data;

  String get id => firestoreDoc.id;
  DocumentReference<T> get reference => firestoreDoc.reference;

  const FirestoreDocument(this.firestoreDoc, this.data);
}

Iterable<FirestoreDocument<T>>? parseFirestoreDocs<T>(AsyncSnapshot<QuerySnapshot<T>> snapshot) {
  return snapshot.data?.docs.expand((doc) {
    try {
      return [
        FirestoreDocument(doc, doc.data())
      ];
    } catch (_) {
      return [];
    }
  });
}
