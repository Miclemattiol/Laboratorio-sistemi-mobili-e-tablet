import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentPartecipant {
  final String userId;
  final double amount;

  const PaymentPartecipant({
    required this.userId,
    required this.amount,
  });
}

class Payment {
  final String category;
  final DateTime date;
  final String description;
  final String from;
  final String imageUrl;
  final num price;
  final String title;
  final Map<String, num> to;

  const Payment({
    required this.category,
    required this.date,
    required this.description,
    required this.from,
    required this.imageUrl,
    required this.price,
    required this.title,
    required this.to,
  }); //! Da modificare quando integreremo con Firebase.
  //! Se il pagamento è stato effettuato dall'utente l'impatto sul suo conto sarà positivo,
  //! altrimenti se è stato effettuato da un altro utente l'impatto sarà negativo o nullo nel caso
  //! in cui l'utente non sia tra i destinatari della pagamento.

  factory Payment.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, [SnapshotOptions? _]) {
    final data = doc.data()!;

    return Payment(
      category: data["category"],
      date: (data["date"] as Timestamp).toDate(),
      description: data["description"],
      from: data["from"],
      imageUrl: data["imageUrl"],
      price: data["price"],
      title: data["title"],
      to: Map.from(data["to"]),
    );
  }

  static Map<String, dynamic> toFirestore(Payment trade, [SetOptions? _]) {
    return {
      "category": trade.category,
      "date": Timestamp.fromDate(trade.date),
      "description": trade.description,
      "from": trade.from,
      "imageUrl": trade.imageUrl,
      "price": trade.price,
      "title": trade.title,
      "to": trade.to,
    };
  }
}
