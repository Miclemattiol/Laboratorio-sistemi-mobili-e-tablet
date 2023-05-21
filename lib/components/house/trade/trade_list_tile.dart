import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house/trade.dart';
import 'package:house_wallet/main.dart';

class TradeListTile extends StatelessWidget {
  final FirestoreDocument<TradeRef> trade; //TODO show other data

  TradeListTile(this.trade) : super(key: Key(trade.id));

  void _confirm(BuildContext context) async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(localizations(context).tradeConfirmDialogTitle),
            content: Text(localizations(context).tradeConfirmDialogContent),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop<bool>(false), child: Text(localizations(context).buttonNo)),
              TextButton(onPressed: () => Navigator.of(context).pop<bool>(true), child: Text(localizations(context).buttonYes)),
            ],
          ),
        ) ??
        false;
    if (!confirm) return;

    trade.reference.update({
      "accepted": true
    });
  }

  void _deny(BuildContext context) async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(localizations(context).tradeDenyDialogTitle),
            content: Text(localizations(context).tradeDenyDialogContent),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop<bool>(false), child: Text(localizations(context).buttonNo)),
              TextButton(onPressed: () => Navigator.of(context).pop<bool>(true), child: Text(localizations(context).buttonYes)),
            ],
          ),
        ) ??
        false;
    if (!confirm) return;

    trade.reference.delete();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const SizedBox(height: double.infinity, child: Icon(FontAwesomeIcons.sackDollar)),
      title: Text(localizations(context).tradeAmount(currencyFormat(context).format(trade.data.amount))),
      subtitle: Text(localizations(context).tradeFrom(trade.data.from.username)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check),
            splashRadius: 24,
            tooltip: localizations(context).tradeConfirmDialogTitle,
            onPressed: () => _confirm(context),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            splashRadius: 24,
            tooltip: localizations(context).tradeDenyDialogTitle,
            onPressed: () => _deny(context),
          )
        ],
      ),
    );
  }
}
