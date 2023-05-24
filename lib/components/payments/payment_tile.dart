import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/payments/payment.dart';
import 'package:house_wallet/main.dart';

class PaymentTile extends StatelessWidget {
  final FirestoreDocument<Payment> doc;

  const PaymentTile(this.doc, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(doc.data.title),
      subtitle: Text(localizations(context).paymentPaidFrom(doc.data.from)),
      leading: const SizedBox(height: double.infinity, child: Icon(Icons.shopping_cart)),
      trailing: PadColumn(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 4,
        children: [
          Text(currencyFormat(context).format(doc.data.price)),
          Text(
            localizations(context).paymentPaidImpact(currencyFormat(context).format(0)),
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
