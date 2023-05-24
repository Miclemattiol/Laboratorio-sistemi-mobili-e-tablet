import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/payments/payment_tile.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/data/payments/payment.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/payments/payment_details_bottom_sheet.dart';

final payments = <Payment>[];

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  static CollectionReference<Payment> get paymentsFirestoreRef => FirebaseFirestore.instance.collection("/groups/${LoggedUser.houseId}/transactions").withConverter(fromFirestore: Payment.fromFirestore, toFirestore: Payment.toFirestore);
  static CollectionReference<Category> get categoriesFirestoreRef => FirebaseFirestore.instance.collection("/groups/${LoggedUser.houseId}/categories").withConverter(fromFirestore: Category.fromFirestore, toFirestore: Category.toFirestore);

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
      body: StreamBuilder(
        stream: categoriesFirestoreRef.snapshots().map(defaultFirestoreConverter),
        builder: (context, snapshot) => StreamBuilder(
          stream: paymentsFirestoreRef.snapshots().asyncMap(PaymentRef.converter(snapshot.data)),
          builder: (context, snapshot) {
            final payments = snapshot.data?.toList();

            if (payments == null) {
              //TODO loading and error messages
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Text("Loading"));
              } else {
                return Center(child: Text("Error (${snapshot.error})"));
              }
            }

            return ListView.separated(
              itemCount: payments.length,
              itemBuilder: (context, index) => PaymentTile(payments[index]),
              separatorBuilder: (context, index) => const Divider(height: 0),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _addPayment(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
