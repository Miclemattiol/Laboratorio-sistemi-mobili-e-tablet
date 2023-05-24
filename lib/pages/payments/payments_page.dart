import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/payments/payment_tile.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/payments/payment.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/payments/payment_details_bottom_sheet.dart';

final payments = <Payment>[];

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  void _addPayment(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const PaymentDetailsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(title: Text(localizations(context).paymentsPage)),
      // body: ListView.separated(
      //   itemCount: payments.length,
      //   itemBuilder: (context, index) => paymentTile(payments[index]),
      //   separatorBuilder: (context, index) => const Divider(height: 0),
      // ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("/groups/${LoggedUser.houseId}/transactions").withConverter(fromFirestore: Payment.fromFirestore, toFirestore: Payment.toFirestore).snapshots().map(defaultFirestoreConverter),
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) {
            return Center(child: Text("Error (${snapshot.error})"));
          }

          return ListView.separated(
            itemCount: data.length,
            itemBuilder: (context, index) => data.map(PaymentTile.new).toList()[index],
            separatorBuilder: (context, index) => const Divider(height: 0),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _addPayment(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
