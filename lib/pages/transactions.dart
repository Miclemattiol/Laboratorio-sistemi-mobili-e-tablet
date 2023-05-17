import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/main.dart';

class Transazione {
  final IconData icon;
  final String title;
  final String from;
  final List<String> to;
  final double amount;
  final DateTime date;
  final double impact;

  Transazione({
    required this.icon,
    required this.title,
    required this.from,
    required this.to,
    required this.amount,
    required this.date,
  }) : impact = amount / to.length; //! Da modificare quando integreremo con Firebase.
  //! Se il pagamento è stato effettiato dall'utente l'impatto sul suo conto sarà positivo,
  //! altrimenti se è stato effettuato da un altro utente l'impatto sarà negativo o nullo nel caso
  //! in cui l'utente non sia tra i destinatari della transazione.
}

class TransazioneTile extends StatelessWidget {
  final Transazione transazione;

  const TransazioneTile(this.transazione, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(transazione.title),
      subtitle: Text(localizations(context).transactionPaidFrom(transazione.from)),
      leading: SizedBox(
        height: double.infinity,
        child: Icon(transazione.icon),
      ),
      trailing: PadColumn(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 4,
        children: [
          Text('€ ${transazione.amount.toStringAsFixed(2)}'),
          Text(
            localizations(context).transactionPaidImpact(transazione.impact.toStringAsFixed(2)),
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

List<Transazione> transazioni = List.from([
  Transazione(
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
  Transazione(
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
  Transazione(
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
  Transazione(
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
  Transazione(
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
  Transazione(
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
  Transazione(
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
  Transazione(
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
  Transazione(
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
  Transazione(
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
  Transazione(
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
  Transazione(
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
  Transazione(
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
  Transazione(
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
  Transazione(
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
]);

class Transactions extends StatelessWidget {
  const Transactions({super.key});

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
        itemCount: transazioni.length,
        itemBuilder: (context, index) => TransazioneTile(transazioni[index]),
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}
