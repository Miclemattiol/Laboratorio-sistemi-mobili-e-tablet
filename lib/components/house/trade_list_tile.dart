import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:house_wallet/data/house/trade.dart';
import 'package:house_wallet/main.dart';

class TradeListTile extends StatelessWidget {
  final Trade trade;
  final void Function()? onAccept;
  final void Function()? onDeny;

  const TradeListTile(
    this.trade, {
    this.onAccept,
    this.onDeny,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const SizedBox(height: double.infinity, child: Icon(FontAwesomeIcons.sackDollar)),
      title: Text(localizations(context).tradeAmount(currencyFormat(context).format(trade.amount))),
      subtitle: Text(localizations(context).tradeFrom(trade.from)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check),
            splashRadius: 24,
            tooltip: localizations(context).tradeConfirm,
            onPressed: onAccept,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            splashRadius: 24,
            tooltip: localizations(context).tradeDeny,
            onPressed: onDeny,
          )
        ],
      ),
    );
  }
}
