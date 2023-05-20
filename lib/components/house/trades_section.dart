import 'package:flutter/material.dart';
import 'package:house_wallet/components/house/section.dart';
import 'package:house_wallet/components/house/trade_list_tile.dart';
import 'package:house_wallet/data/house/trade.dart';
import 'package:house_wallet/main.dart';

const trades = <Trade>[
  Trade(amount: 20, from: "Mario Rossi"),
  Trade(amount: 500, from: "Brutto Signore"),
];

class TradesSection extends StatelessWidget {
  const TradesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Section(
      title: localizations(context).tradesSection,
      children: trades.map((trade) {
        return TradeListTile(
          trade,
          onAccept: () {},
          onDeny: () {},
        );
      }).toList(),
    );
  }
}
