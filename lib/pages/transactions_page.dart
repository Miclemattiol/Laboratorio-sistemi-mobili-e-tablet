import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/form/number_form_field.dart';
import 'package:house_wallet/components/transactions/transaction_tile.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/components/ui/bottom_sheet_container.dart';
import 'package:house_wallet/data/transactions/transaction.dart';
import 'package:house_wallet/main.dart';

final transactions = <Transaction>[
  Transaction(
    title: "Spesa al supermercato",
    icon: Icons.shopping_cart,
    from: "Mario",
    to: [
      "Mario",
      "Luigi",
      "Peach",
      "Toad"
    ],
    amount: 100.0,
    date: DateTime.now(),
  ),
  Transaction(
    title: "Spesa al macellaio",
    icon: Icons.shopping_cart,
    from: "Mario",
    to: [
      "Mario",
      "Luigi",
      "Peach",
      "Toad"
    ],
    amount: 80.0,
    date: DateTime.now(),
  ),
  Transaction(
    title: "Spesa al fruttivendolo",
    icon: Icons.shopping_cart,
    from: "Mario",
    to: [
      "Mario",
      "Luigi",
      "Peach",
      "Toad"
    ],
    amount: 50.0,
    date: DateTime.now(),
  ),
  Transaction(
    title: "Spesa al panettiere",
    icon: Icons.shopping_cart,
    from: "Mario",
    to: [
      "Mario",
      "Luigi",
      "Peach",
      "Toad"
    ],
    amount: 20.0,
    date: DateTime.now(),
  ),
  Transaction(
    title: "Spesa al supermercato",
    icon: Icons.shopping_cart,
    from: "Mario",
    to: [
      "Mario",
      "Luigi",
      "Peach",
      "Toad"
    ],
    amount: 100.0,
    date: DateTime.now(),
  ),
  Transaction(
    title: "Spesa al supermercato",
    icon: Icons.shopping_cart,
    from: "Mario",
    to: [
      "Mario",
      "Luigi",
      "Peach",
      "Toad"
    ],
    amount: 100.0,
    date: DateTime.now(),
  ),
  Transaction(
    title: "Spesa al macellaio",
    icon: Icons.shopping_cart,
    from: "Mario",
    to: [
      "Mario",
      "Luigi",
      "Peach",
      "Toad"
    ],
    amount: 80.0,
    date: DateTime.now(),
  ),
  Transaction(
    title: "Spesa al fruttivendolo",
    icon: Icons.shopping_cart,
    from: "Mario",
    to: [
      "Mario",
      "Luigi",
      "Peach",
      "Toad"
    ],
    amount: 50.0,
    date: DateTime.now(),
  ),
  Transaction(
    title: "Spesa al panettiere",
    icon: Icons.shopping_cart,
    from: "Mario",
    to: [
      "Mario",
      "Luigi",
      "Peach",
      "Toad"
    ],
    amount: 20.0,
    date: DateTime.now(),
  ),
  Transaction(
    title: "Spesa al supermercato",
    icon: Icons.shopping_cart,
    from: "Mario",
    to: [
      "Mario",
      "Luigi",
      "Peach",
      "Toad"
    ],
    amount: 100.0,
    date: DateTime.now(),
  ),
  Transaction(
    title: "Spesa al supermercato",
    icon: Icons.shopping_cart,
    from: "Mario",
    to: [
      "Mario",
      "Luigi",
      "Peach",
      "Toad"
    ],
    amount: 100.0,
    date: DateTime.now(),
  ),
  Transaction(
    title: "Spesa al macellaio",
    icon: Icons.shopping_cart,
    from: "Mario",
    to: [
      "Mario",
      "Luigi",
      "Peach",
      "Toad"
    ],
    amount: 80.0,
    date: DateTime.now(),
  ),
  Transaction(
    title: "Spesa al fruttivendolo",
    icon: Icons.shopping_cart,
    from: "Mario",
    to: [
      "Mario",
      "Luigi",
      "Peach",
      "Toad"
    ],
    amount: 50.0,
    date: DateTime.now(),
  ),
  Transaction(
    title: "Spesa al panettiere",
    icon: Icons.shopping_cart,
    from: "Mario",
    to: [
      "Mario",
      "Luigi",
      "Peach",
      "Toad"
    ],
    amount: 20.0,
    date: DateTime.now(),
  ),
  Transaction(
    title: "Spesa al supermercato",
    icon: Icons.shopping_cart,
    from: "Mario",
    to: [
      "Mario",
      "Luigi",
      "Peach",
      "Toad"
    ],
    amount: 100.0,
    date: DateTime.now(),
  ),
];

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  void _addTransaction(BuildContext context) {
    //TODO add transaction
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => const _TransactionsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(title: Text(localizations(context).transactionsPage)),
      body: ListView.separated(
        itemCount: transactions.length,
        itemBuilder: (context, index) => TransactionTile(transactions[index]),
        separatorBuilder: (context, index) => const Divider(height: 0),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _addTransaction(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TransactionsBottomSheet extends StatelessWidget {
  const _TransactionsBottomSheet();

  @override
  Widget build(BuildContext context) {
    return BottomSheetContainer(
      padding: const EdgeInsets.all(16),
      child: Form(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PadRow(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 32,
                children: [
                  const SizedBox(width: 64, height: 64, child: Placeholder()),
                  Expanded(
                    child: Center(
                      child: TextFormField(
                        decoration: InputDecoration(border: const OutlineInputBorder(), labelText: localizations(context).title),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 64,
                    child: NumberFormField(
                      decoration: InputDecoration(border: const OutlineInputBorder(), labelText: localizations(context).price),
                      decimal: true,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
