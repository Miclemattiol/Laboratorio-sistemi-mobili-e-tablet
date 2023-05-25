import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/payments/payment.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/payments/payment_details_bottom_sheet.dart';

class PaymentTile extends StatelessWidget {
  final FirestoreDocument<PaymentRef> doc;

  const PaymentTile(this.doc, {Key? key}) : super(key: key);

  num _calculateImpact(PaymentRef payment) {
    final totalShares = payment.to.values.fold<num>(0, (prev, element) => prev + element.share);
    final pricePerShare = payment.price / totalShares;
    final myShare = payment.to[LoggedUser.uid]?.share;

    if (payment.from.uid == LoggedUser.uid) {
      if (payment.to.containsKey(LoggedUser.uid)) {
        return pricePerShare * (totalShares - myShare!);
      } else {
        return payment.price;
      }
    } else if (payment.to.containsKey(LoggedUser.uid)) {
      return -pricePerShare * myShare!;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final payment = doc.data;
    return ListTile(
      title: Text(payment.title),
      subtitle: Text(localizations(context).paymentPaidFrom(payment.from.username)),
      leading: const SizedBox(height: double.infinity, child: Icon(Icons.shopping_cart)),
      trailing: PadColumn(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 4,
        children: [
          Text(currencyFormat(context).format(payment.price)),
          Text(
            localizations(context).paymentPaidImpact(currencyFormat(context).format(_calculateImpact(payment))),
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => PaymentDetailsBottomSheet.edit(doc),
      ),
    );
  }
}
