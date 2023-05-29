import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/house/trade/trades_section.dart';
import 'package:house_wallet/components/payments/payment_tile.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/components/ui/sliding_page_route.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house/trade.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/data/payments/payment.dart';
import 'package:house_wallet/data/payments/payment_filter.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/payments/categories_page.dart';
import 'package:house_wallet/pages/payments/filter_bottom_sheet.dart';
import 'package:house_wallet/pages/payments/payment_details_bottom_sheet.dart';
import 'package:house_wallet/themes.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shimmer/shimmer.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  static CollectionReference<Payment> paymentsFirestoreRef(String houseId) => FirebaseFirestore.instance.collection("/groups/$houseId/transactions").withConverter(fromFirestore: Payment.fromFirestore, toFirestore: Payment.toFirestore);
  static CollectionReference<Category> categoriesFirestoreRef(String houseId) => FirebaseFirestore.instance.collection("/groups/$houseId/categories").withConverter(fromFirestore: Category.fromFirestore, toFirestore: Category.toFirestore);

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final _paymentFilter = PaymentFilter();

  void _addPayment(BuildContext context) {
    final loggedUser = LoggedUser.of(context, listen: false);
    final house = HouseDataRef.of(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) => PaymentDetailsBottomSheet(loggedUser: loggedUser, house: house),
    );
  }

  void _filter(BuildContext context) {
    final house = HouseDataRef.of(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) => FilterBottomSheet(house: house, filter: _paymentFilter,),
    );
  }

  @override
  Widget build(BuildContext context) {
    final houseId = HouseDataRef.of(context).id;
    return Scaffold(
      appBar: AppBarFix(
        title: Text(localizations(context).paymentsPage),
        actions: [
          IconButton(
            tooltip: localizations(context).filterTooltip,
            onPressed: () => _filter(context),
            icon: const Icon(Icons.filter_alt),
          ),
          IconButton(
            tooltip: localizations(context).categoriesPage,
            onPressed: () => Navigator.of(context).push(SlidingPageRoute(const CategoriesPage(), fullscreenDialog: true)),
            icon: const Icon(Icons.segment),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: PaymentsPage.categoriesFirestoreRef(houseId).snapshots().map(defaultFirestoreConverter),
        builder: (context, snapshot) => StreamBuilder(
          stream: Rx.combineLatest2(
            PaymentsPage.paymentsFirestoreRef(houseId).snapshots().map(PaymentRef.converter(context, snapshot.data)),
            TradesSection.firestoreRef(HouseDataRef.of(context).id).where("accepted", isEqualTo: true).snapshots().map(TradeRef.converter(context)),
            (payments, trades) => [
              ...payments,
              ...trades
            ].toList()
              ..sort((payment, trade) => trade.data.date.compareTo(payment.data.date)),
          ),
          builder: (context, snapshot) {
            final payments = snapshot.data;

            if (payments == null) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Shimmer.fromColors(
                  baseColor: Theme.of(context).disabledColor,
                  highlightColor: Theme.of(context).disabledColor.withOpacity(.1),
                  child: ListView(
                    children: [
                      PaymentTile.shimmer(titleWidth: 128, subtitleWidth: 96),
                      PaymentTile.shimmer(titleWidth: 160, subtitleWidth: 96),
                      PaymentTile.shimmer(titleWidth: 96, subtitleWidth: 80),
                      PaymentTile.shimmer(titleWidth: 112, subtitleWidth: 40),
                      PaymentTile.shimmer(titleWidth: 96, subtitleWidth: 32),
                      PaymentTile.shimmer(titleWidth: 160, subtitleWidth: 96),
                      PaymentTile.shimmer(titleWidth: 96, subtitleWidth: 80),
                      PaymentTile.shimmer(titleWidth: 128, subtitleWidth: 96),
                    ],
                  ),
                );
              } else {
                return centerErrorText(context: context, message: localizations(context).paymentsPageError, error: snapshot.error);
              }
            }

            //TODO empty list
            if (payments.isEmpty) {
              return const Center(child: Text("🗿", style: TextStyle(fontSize: 64)));
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
