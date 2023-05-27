import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/payments/payment_tile.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/data/payments/payment.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/payments/payment_details_bottom_sheet.dart';

final payments = <Payment>[];

//TODO aggiungere anche gli scambi di denaro accettati
class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  static CollectionReference<Payment> paymentsFirestoreRef(String houseId) => FirebaseFirestore.instance.collection("/groups/$houseId/transactions").withConverter(fromFirestore: Payment.fromFirestore, toFirestore: Payment.toFirestore);
  static CollectionReference<Category> categoriesFirestoreRef(String houseId) => FirebaseFirestore.instance.collection("/groups/$houseId/categories").withConverter(fromFirestore: Category.fromFirestore, toFirestore: Category.toFirestore);

  void _addPayment(BuildContext context) {
    final loggedUser = LoggedUser.of(context, listen: false);
    final house = HouseDataRef.of(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PaymentDetailsBottomSheet(loggedUser: loggedUser, house: house),
    );
  }

  @override
  Widget build(BuildContext context) {
    final houseId = HouseDataRef.of(context).id;
    return Scaffold(
      appBar: AppBarFix(title: Text(localizations(context).paymentsPage)),
      body: StreamBuilder(
        stream: categoriesFirestoreRef(houseId).snapshots().map(defaultFirestoreConverter),
        builder: (context, snapshot) => StreamBuilder(
          stream: paymentsFirestoreRef(houseId).snapshots().map(PaymentRef.converter(context, snapshot.data)),
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
