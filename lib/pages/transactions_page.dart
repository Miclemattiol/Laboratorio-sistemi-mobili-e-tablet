import 'package:flutter/material.dart';
import 'package:house_wallet/components/transactions/transaction_tile.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(title: Text(localizations(context).transactionsPage)),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        itemCount: transactions.length,
        itemBuilder: (context, index) => TransactionTile(transactions[index]),
        separatorBuilder: (context, index) => const Divider(height: 0),
      ),
    );
  }
}
