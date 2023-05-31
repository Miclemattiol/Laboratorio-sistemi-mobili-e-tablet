import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/payment_or_trade.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/data/payments/payment.dart';
import 'package:house_wallet/data/payments/trade.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/payments/payment_details_bottom_sheet.dart';
import 'package:house_wallet/pages/payments/trade_details_bottom_sheet.dart';

class PaymentTile extends StatelessWidget {
  final List<FirestoreDocument<Category>> categories;
  final FirestoreDocument<PaymentOrTrade> doc;

  PaymentTile(
    this.doc, {
    required this.categories,
  }) : super(key: Key(doc.id));

  static Widget shimmer({required double titleWidth, required double subtitleWidth}) {
    return PadRow(
      crossAxisAlignment: CrossAxisAlignment.center,
      padding: const EdgeInsets.all(19) + const EdgeInsets.only(right: 5),
      children: [
        Container(width: 24, height: 24, color: Colors.white),
        Expanded(
          child: PadColumn(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            spacing: 6,
            children: [
              Container(height: 14, width: titleWidth, color: Colors.white),
              Container(height: 14, width: subtitleWidth, color: Colors.white)
            ],
          ),
        ),
        PadColumn(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 4,
          children: [
            Container(height: 12, width: 50, color: Colors.white),
            Container(height: 12, width: 25, color: Colors.white),
          ],
        )
      ],
    );
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

  String _title(BuildContext context) {
    final payment = doc.data;
    final myUid = LoggedUser.of(context).uid;

    if (payment is PaymentRef) {
      return payment.title;
    } else {
      final trade = payment as TradeRef;
      if (trade.from.uid == myUid) {
        return localizations(context).tradeFromMe;
      } else if (trade.to.uid == myUid) {
        return localizations(context).tradeToMe;
      } else {
        return localizations(context).tradeOthers(trade.to.username);
      }
    }
  }

  String _subtitle(BuildContext context) {
    final payment = doc.data;
    final myUid = LoggedUser.of(context).uid;

    if (payment is PaymentRef) {
      return localizations(context).paymentPaidFrom(payment.from.username);
    } else {
      final trade = payment as TradeRef;
      if (trade.from.uid == myUid) {
        return localizations(context).tradeTo(trade.to.username);
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
      return Text(currencyFormat(context).format(trade.price));
    }
  }

  IconData _leading(BuildContext context) {
    final payment = doc.data;
    if (payment is PaymentRef) {
      return payment.category?.data.icon ?? Icons.shopping_cart;
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

  void _onTap(BuildContext context) {
    final payment = doc.data;
    final loggedUser = LoggedUser.of(context, listen: false);
    final house = HouseDataRef.of(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) {
        if (payment is PaymentRef) {
          return PaymentDetailsBottomSheet.edit(doc as FirestoreDocument<PaymentRef>, loggedUser: loggedUser, house: house, categories: categories);
        } else {
          return TradeDetailsBottomSheet.edit(doc as FirestoreDocument<TradeRef>, loggedUser: loggedUser, house: house);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
        onTap: () => _onTap(context),
      ),
    );
  }
}
