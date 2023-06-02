import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/house/section.dart';
import 'package:house_wallet/components/house/trade/trade_list_tile.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/payments/trade.dart';
import 'package:house_wallet/main.dart';

class TradesSection extends StatelessWidget {
  final AsyncSnapshot<Iterable<FirestoreDocument<TradeRef>>> snapshot;

  const TradesSection(this.snapshot, {super.key});

  static CollectionReference<Trade> firestoreRef(String houseId) => FirebaseFirestore.instance.collection("/groups/$houseId/trades").withConverter(fromFirestore: Trade.fromFirestore, toFirestore: Trade.toFirestore);

  @override
  Widget build(BuildContext context) {
    final trades = snapshot.data;
    return Section(
      title: localizations(context).tradesSection,
      children: () {
        if (trades == null) {
          return [ListTile(title: Text("${localizations(context).tradesSectionError} (${snapshot.error})"))];
        }

        return trades.map(TradeListTile.new).toList();
      }(),
    );
  }
}
