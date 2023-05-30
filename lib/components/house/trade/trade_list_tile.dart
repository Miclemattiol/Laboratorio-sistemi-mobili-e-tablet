import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/shopping/trade.dart';
import 'package:house_wallet/main.dart';

class TradeListTile extends StatelessWidget {
  final FirestoreDocument<TradeRef> trade; //TODO show description in some way

  TradeListTile(this.trade) : super(key: Key(trade.id));

  void _confirm(BuildContext context) async {
    if (!await CustomDialog.confirm(
      context: context,
      title: localizations(context).tradeConfirmDialogTitle,
      content: localizations(context).tradeConfirmDialogContent,
    )) return;

    trade.reference.update({
      Trade.acceptedKey: true
    });
  }

  void _deny(BuildContext context) async {
    if (!await CustomDialog.confirm(
      context: context,
      title: localizations(context).tradeDenyDialogTitle,
      content: localizations(context).tradeDenyDialogContent,
    )) return;

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
