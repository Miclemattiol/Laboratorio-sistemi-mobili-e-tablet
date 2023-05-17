import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/data/transactions/transaction.dart';
import 'package:house_wallet/main.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transazione;

  const TransactionTile(this.transazione, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(transazione.title),
      subtitle: Text(localizations(context).transactionPaidFrom(transazione.from)),
      leading: SizedBox(
        height: double.infinity,
        child: Icon(transazione.icon),
      ),
      trailing: PadColumn(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 4,
        children: [
          Text('€ ${transazione.amount.toStringAsFixed(2)}'),
          Text(
            localizations(context).transactionPaidImpact(transazione.impact.toStringAsFixed(2)),
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
