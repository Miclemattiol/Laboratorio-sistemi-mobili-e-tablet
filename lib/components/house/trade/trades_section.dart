import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/house/section.dart';
import 'package:house_wallet/components/house/trade/trade_list_tile.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house/trade.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/main.dart';

class TradesSection extends StatelessWidget {
  final AsyncSnapshot<Iterable<FirestoreDocument<TradeRef>>> snapshot;

  const TradesSection(this.snapshot, {super.key});

  static CollectionReference<Trade> get firestoreRef => FirebaseFirestore.instance.collection("/groups/${LoggedUser.houseId!}/trades").withConverter(fromFirestore: Trade.fromFirestore, toFirestore: Trade.toFirestore);

  @override
  Widget build(BuildContext context) {
    final data = snapshot.data;
    return Section(
      title: localizations(context).tradesSection,
      children: () {
        if (data == null) {
          return [
            Center(child: Text("Error (${snapshot.error})")) //TODO error message
          ];
        }

        return data.map(TradeListTile.new).toList();
      }(),
    );
  }
}
