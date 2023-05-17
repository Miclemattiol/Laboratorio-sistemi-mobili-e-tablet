import 'package:flutter/material.dart';

class Transaction {
  final IconData icon;
  final String title;
  final String from;
  final List<String> to;
  final double amount;
  final DateTime date;
  final double impact;

  const Transaction({
    required this.icon,
    required this.title,
    required this.from,
    required this.to,
    required this.amount,
    required this.date,
  }) : impact = amount / to.length; //! Da modificare quando integreremo con Firebase.
  //! Se il pagamento è stato effettuato dall'utente l'impatto sul suo conto sarà positivo,
  //! altrimenti se è stato effettuato da un altro utente l'impatto sarà negativo o nullo nel caso
  //! in cui l'utente non sia tra i destinatari della transazione.
}
