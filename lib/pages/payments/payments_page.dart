import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/house/trade/trades_section.dart';
import 'package:house_wallet/components/payments/payment_tile.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/components/ui/sliding_page_route.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/payment_or_trade.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/data/payments/payment.dart';
import 'package:house_wallet/data/payments/trade.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/payments/categories/categories_page.dart';
import 'package:house_wallet/pages/payments/filter_bottom_sheet.dart';
import 'package:house_wallet/pages/payments/payment_details_bottom_sheet.dart';
import 'package:house_wallet/themes.dart';
import 'package:house_wallet/utils.dart';
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
  PaymentFilter _paymentFilter = PaymentFilter();

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

  void _filter(BuildContext context) async {
    final house = HouseDataRef.of(context, listen: false);

    final filter = await showModalBottomSheet<PaymentFilter>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) => FilterBottomSheet(
        house: house,
        currentFilter: _paymentFilter,
      ),
    );
    if (filter == null) return;

    setState(() => _paymentFilter = filter);
  }

  List<FirestoreDocument<PaymentOrTrade>> _filteredData(List<FirestoreDocument<PaymentOrTrade>> data) {
    return data.where((element) {
      //TODO use filters here: use only rules like this: if(!followsFilters) return false, if everything fails return true at the end of the function!
      // if (element.data is PaymentRef) {
      //   final payment = element.data as PaymentRef;
      //   if (_paymentFilter.titleShouldMatch != null && !payment.title.containsCaseUnsensitive(_paymentFilter.titleShouldMatch!)) return false; //TODO make case insensitive
      //   if (_paymentFilter.priceRange?.test(payment.price) == false) return false;
      //   if (_paymentFilter.categoryId != null && (_paymentFilter.categoryId?.contains(payment.category?.name) ?? false) == false) return false; //TODO get payment category ID
      //   if (_paymentFilter.fromUser != null && (_paymentFilter.fromUser?.contains(payment.from.uid) ?? false) == false) return false; //TODO get payment paidBy
      // } else {
      //   final trade = element.data as TradeRef;
      //   if (_paymentFilter.titleShouldMatch != null) return false;
      //   if (_paymentFilter.priceRange?.test(trade.amount) == false) return false;
      // }
      if (_paymentFilter.titleShouldMatch != null && element.data is TradeRef) return false;
      if (_paymentFilter.categoryId != null && element.data is TradeRef) return false;
      if (_paymentFilter.dateRange?.test(element.data.date) == false) return false;

      if (element.data is PaymentRef) {
        final payment = element.data as PaymentRef;
        if (_paymentFilter.titleShouldMatch != null && !payment.title.containsCaseUnsensitive(_paymentFilter.titleShouldMatch!)) return false;
        if (_paymentFilter.priceRange?.test(payment.price) == false) return false;
        // TODO category
        if (_paymentFilter.descriptionShouldMatch != null && !payment.description.containsCaseUnsensitive(_paymentFilter.descriptionShouldMatch!)) return false;
      } else {
        final trade = element.data as TradeRef;
        if (_paymentFilter.priceRange?.test(trade.amount) == false) return false;
        if (_paymentFilter.descriptionShouldMatch != null && !trade.description.containsCaseUnsensitive(_paymentFilter.descriptionShouldMatch!)) return false;
      }

      return true;
    }).toList();
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
          if (!_paymentFilter.empty)
            IconButton(
              tooltip: localizations(context).clearFilterTooltip,
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () {
                setState(() => _paymentFilter = PaymentFilter());
              },
            ),
          IconButton(
            tooltip: localizations(context).categoriesPage,
            onPressed: () => Navigator.of(context).push(SlidingPageRoute(CategoriesPage(house: HouseDataRef.of(context, listen: false)), fullscreenDialog: true)),
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

            final filteredPayments = _filteredData(payments);
            //TODO empty list with filters
            if (filteredPayments.isEmpty) {
              return const Center(child: Text("🗿 (filtri)", style: TextStyle(fontSize: 64)));
            }

            return ListView.separated(
              itemCount: filteredPayments.length,
              itemBuilder: (context, index) => PaymentTile(filteredPayments[index]),
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
