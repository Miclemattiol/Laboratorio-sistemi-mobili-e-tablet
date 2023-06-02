import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/payments/trade.dart';
import 'package:house_wallet/main.dart';

class TradeListTile extends StatelessWidget {
  final FirestoreDocument<TradeRef> trade;

  TradeListTile(this.trade) : super(key: Key(trade.id));

  void _confirm(BuildContext context) async {
    if (!await CustomDialog.confirm(
      context: context,
      title: localizations(context).tradeConfirmTitle,
      content: "${trade.data.description ?? "(Nessuna descrizione fornita)"}\n\n${localizations(context).tradeConfirmContent}",
    )) return;

    trade.reference.update({
      Trade.acceptedKey: true,
    });
  }

  void _deny(BuildContext context) async {
    if (!await CustomDialog.confirm(
      context: context,
      title: localizations(context).tradeDenyTitle,
      content: "${trade.data.description ?? "(Nessuna descrizione fornita)"}\n\n${localizations(context).tradeDenyContent}",
    )) return;

    trade.reference.delete();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const SizedBox(height: double.infinity, child: Icon(FontAwesomeIcons.sackDollar)),
      title: Text(localizations(context).tradeAmount(currencyFormat(context).format(trade.data.price))),
      subtitle: Text(localizations(context).tradeFrom(trade.data.from.username)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check),
            splashRadius: 24,
            tooltip: localizations(context).tradeConfirmTitle,
            onPressed: () => _confirm(context),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            splashRadius: 24,
            tooltip: localizations(context).tradeDenyTitle,
            onPressed: () => _deny(context),
          )
        ],
      ),
    );
  }
}
