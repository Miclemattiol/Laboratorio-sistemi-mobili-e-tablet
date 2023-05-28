import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house/trade.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/payment_trade.dart';
import 'package:house_wallet/data/payments/payment.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/payments/payment_details_bottom_sheet.dart';
import 'package:house_wallet/pages/payments/trade_details_bottom_sheet.dart';

class PaymentTile extends StatelessWidget {
  final FirestoreDocument<PaymentTrade> doc;

  const PaymentTile(this.doc, {Key? key}) : super(key: key);

  String _title(BuildContext context) {
    final payment = doc.data;
    if (payment is PaymentRef) {
      return payment.title;
    } else {
      final trade = payment as TradeRef;
      if (trade.from.uid == LoggedUser.of(context).uid) {
        return localizations(context).tradeFromMe;
      } else if (trade.to.uid == LoggedUser.of(context).uid) {
        return localizations(context).tradeToMe;
      } else {
        return localizations(context).tradeNotMe(trade.to.username); //TODO Dargli un nome migliore
      }
    }
  }

  String _subtitle(BuildContext context) {
    final payment = doc.data;
    if (payment is PaymentRef) {
      return localizations(context).paymentPaidFrom(payment.from.username);
    } else {
      final trade = payment as TradeRef;
      if (trade.from.uid == LoggedUser.of(context).uid) {
        return localizations(context).tradeTo(trade.to.username);
      } else if (trade.to.uid == LoggedUser.of(context).uid) {
        return localizations(context).tradeFrom(trade.from.username);
      } else {
        return localizations(context).tradeFrom(trade.from.username);
      }
    }
  }

  Widget _trailing(BuildContext context) {
    final payment = doc.data;
    if (payment is PaymentRef) {
      return PadColumn(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 4,
        children: [
          Text(currencyFormat(context).format(payment.price)),
          Text(
            localizations(context).paymentPaidImpact(currencyFormat(context).format(_calculateImpact(LoggedUser.of(context), payment))),
            style: const TextStyle(fontSize: 10),
          ),
        ],
      );
    } else {
      final trade = payment as TradeRef;
      trade;
      return Text(currencyFormat(context).format(trade.amount));
    }
  }

  IconData _leading(BuildContext context) {
    final payment = doc.data;
    if (payment is PaymentRef) {
      return payment.category?.icon ?? Icons.shopping_cart;
    } else {
      final trade = payment as TradeRef;
      if (trade.from.uid == LoggedUser.of(context).uid) {
        return Icons.subdirectory_arrow_right;
      } else if (trade.to.uid == LoggedUser.of(context).uid) {
        return Icons.subdirectory_arrow_left;
      } else {
        return Icons.compare_arrows;
      }
    }
  }

  num _calculateImpact(LoggedUser loggedUser, PaymentRef payment) {
    final totalShares = payment.to.values.fold<num>(0, (prev, element) => prev + element.share);
    final pricePerShare = payment.price / totalShares;
    final myShare = payment.to[loggedUser.uid]?.share;

    if (payment.from.uid == loggedUser.uid) {
      if (payment.to.containsKey(loggedUser.uid)) {
        return pricePerShare * (totalShares - myShare!);
      } else {
        return payment.price;
      }
    } else if (payment.to.containsKey(loggedUser.uid)) {
      return -pricePerShare * myShare!;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final payment = doc.data;
    return Slidable(
      key: Key(doc.id),
      endActionPane: ActionPane(
        extentRatio: .2,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => doc.reference.delete(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
          ),
        ],
      ),
      child: ListTile(
        title: Text(_title(context)),
        subtitle: Text(_subtitle(context)),
        leading: SizedBox(height: double.infinity, child: Icon(_leading(context))),
        trailing: _trailing(context),
        onTap: () {
          final loggedUser = LoggedUser.of(context, listen: false);
          final house = HouseDataRef.of(context, listen: false);
          if (payment is PaymentRef) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              enableDrag: false,
              builder: (context) => PaymentDetailsBottomSheet.edit(doc as FirestoreDocument<PaymentRef>, loggedUser: loggedUser, house: house),
            );
          } else {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              enableDrag: false,
              builder: (context) => TradeDetailsBottomSheet.edit(doc as FirestoreDocument<TradeRef>, loggedUser: loggedUser, house: house),
            );
          }
        },
      ),
    );
  }
}
