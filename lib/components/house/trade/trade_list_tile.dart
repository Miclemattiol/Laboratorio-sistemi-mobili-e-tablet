import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/payments/trade.dart';
import 'package:house_wallet/main.dart';

class TradeListTile extends StatelessWidget {
  final FirestoreDocument<TradeRef> trade;

  TradeListTile(this.trade) : super(key: Key(trade.id));

  void _confirm(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final appLocalizations = localizations(context);

    if (!await CustomDialog.confirm(
      context: context,
      title: localizations(context).tradeConfirmTitle,
      content: "${trade.data.description ?? localizations(context).tradeDescriptionMissing}\n\n${localizations(context).tradeConfirmContent}",
    )) return;

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(
          trade.reference,
          {
            Trade.acceptedKey: true,
          },
        );

        HouseDataRef.of(context, listen: false).updateBalances(
          transaction,
          newValues: SharesData(from: trade.data.from.uid, price: trade.data.price, shares: trade.data.shares),
        );
      });
    } on FirebaseException catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(error.code == HouseDataRef.invalidUsersError ? appLocalizations.balanceInvalidUser : appLocalizations.saveChangesError(error.message.toString()))));
    }
  }

  void _deny(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final appLocalizations = localizations(context);

    if (!await CustomDialog.confirm(
      context: context,
      title: localizations(context).tradeDenyTitle,
      content: "${trade.data.description ?? localizations(context).tradeDescriptionMissing}\n\n${localizations(context).tradeDenyContent}",
    )) return;

    try {
      await trade.reference.delete();
    } on FirebaseException catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(appLocalizations.actionError(error.message.toString()))));
    }
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
