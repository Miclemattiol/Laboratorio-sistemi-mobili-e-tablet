import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:house_wallet/components/house/trade/trades_section.dart';
import 'package:house_wallet/components/payments/payment_tile.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/components/ui/sliding_page_route.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/data/payments/payment.dart';
import 'package:house_wallet/data/payments/trade.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/payments/categories/categories_page.dart';
import 'package:house_wallet/pages/payments/filter_bottom_sheet.dart';
import 'package:house_wallet/pages/payments/payment_details_bottom_sheet.dart';
import 'package:house_wallet/themes.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shimmer/shimmer.dart';

class PaymentsPage extends StatefulWidget {
  final Categories categories;

  const PaymentsPage(this.categories, {super.key});

  static CollectionReference<Payment> paymentsFirestoreRef(String houseId) => FirebaseFirestore.instance.collection("/groups/$houseId/transactions").withConverter(fromFirestore: Payment.fromFirestore, toFirestore: Payment.toFirestore);
  static CollectionReference<Category> categoriesFirestoreRef(String houseId) => FirebaseFirestore.instance.collection("/groups/$houseId/categories").withConverter(fromFirestore: Category.fromFirestore, toFirestore: Category.toFirestore);

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  bool _showFab = true;
  PaymentFilter _paymentFilter = const PaymentFilter.empty();

  void _addPayment(BuildContext context) {
    final loggedUser = LoggedUser.of(context, listen: false);
    final house = HouseDataRef.of(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) => PaymentDetailsBottomSheet(loggedUser: loggedUser, house: house, categories: widget.categories),
    );
  }

  void _filter(BuildContext context) async {
    final house = HouseDataRef.of(context, listen: false);
    final filter = await showModalBottomSheet<PaymentFilter>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) => FilterBottomSheet(house: house, currentFilter: _paymentFilter, categories: widget.categories),
    );
    if (filter == null) return;
    setState(() => _paymentFilter = filter);
  }

  @override
  Widget build(BuildContext context) {
    final houseId = HouseDataRef.of(context).id;
    return Scaffold(
      appBar: AppBarFix(
        title: Text(localizations(context).paymentsPage),
        actions: [
          if (!_paymentFilter.isEmpty)
            IconButton(
              key: const Key("resetFilter"),
              tooltip: localizations(context).clearFilterTooltip,
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () => setState(() => _paymentFilter = const PaymentFilter.empty()),
            ),
          IconButton(
            key: const Key("filter"),
            tooltip: localizations(context).filterTooltip,
            onPressed: () => _filter(context),
            icon: const Icon(Icons.filter_alt),
          ),
          IconButton(
            key: const Key("categories"),
            tooltip: localizations(context).categoriesPage,
            onPressed: () => Navigator.of(context).push(SlidingPageRoute(CategoriesPage(house: HouseDataRef.of(context, listen: false)), fullscreenDialog: true)),
            icon: const Icon(Icons.segment),
          )
        ],
      ),
      body: StreamBuilder(
        stream: Rx.combineLatest2(
          PaymentsPage.paymentsFirestoreRef(houseId).snapshots().map(PaymentRef.converter(context, widget.categories)),
          TradesSection.firestoreRef(HouseDataRef.of(context).id).where(Trade.acceptedKey, isEqualTo: true).snapshots().map(TradeRef.converter(context)),
          (payments, trades) => [...payments, ...trades].toList()..sort((payment, trade) => trade.data.date.compareTo(payment.data.date)),
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

          if (payments.isEmpty) {
            return centerSectionText(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(localizations(context).paymentsPageEmpty, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                  Text(localizations(context).paymentsPageEmptyDescription, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.normal)),
                ],
              ),
            );
          }

          final filteredPayments = _paymentFilter.filterData(payments);
          if (filteredPayments.isEmpty) {
            return centerSectionText(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(localizations(context).paymentsPageEmpty, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                  Text(localizations(context).paymentsPageEmptyFilterDescription, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.normal)),
                ],
              ),
            );
          }

          return NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              setState(() => _showFab = notification.direction == ScrollDirection.idle);
              return true;
            },
            child: ListView.separated(
              itemCount: filteredPayments.length,
              itemBuilder: (context, index) => PaymentTile(filteredPayments[index], categories: widget.categories),
              separatorBuilder: (context, index) => const Divider(height: 0),
            ),
          );
        },
      ),
      floatingActionButton: _showFab
          ? FloatingActionButton(
              heroTag: null,
              onPressed: () => _addPayment(context),
              tooltip: localizations(context).paymentsPageNew,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
