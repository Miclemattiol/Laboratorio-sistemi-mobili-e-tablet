import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/payments/payment.dart';
import 'package:house_wallet/main.dart';

class PaymentTile extends StatelessWidget {
  final FirestoreDocument<Payment> doc;

  const PaymentTile(this.doc, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    num impact;
    print(LoggedUser.uid);
    if (doc.data.from == LoggedUser.uid) {
      num nParts = 0;
      doc.data.to.forEach((key, value) {
        nParts += value;
      });
      if (doc.data.to.containsKey(LoggedUser.uid)) {
        impact = (doc.data.price / nParts) * (nParts - doc.data.to[LoggedUser.uid]!);
      } else {
        impact = doc.data.price;
      }
    } else if (doc.data.to.containsKey(LoggedUser.uid)) {
      num nParts = 0;
      doc.data.to.forEach((key, value) {
        nParts += value;
      });
      impact = -(doc.data.price / nParts) * doc.data.to[LoggedUser.uid]!;
    } else {
      impact = 0;
    }

    return ListTile(
      title: Text(doc.data.title),
      subtitle: FutureBuilder(future: FirestoreData.getUser(doc.data.from), builder: (context, snapshot) => Text(localizations(context).paymentPaidFrom(snapshot.data!.username))),
      leading: const SizedBox(height: double.infinity, child: Icon(Icons.shopping_cart)),
      trailing: PadColumn(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 4,
        children: [
          Text(currencyFormat(context).format(doc.data.price)),
          Text(
            localizations(context).paymentPaidImpact(currencyFormat(context).format(impact)),
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
