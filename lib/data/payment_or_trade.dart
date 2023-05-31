import 'package:house_wallet/data/user.dart';

abstract class PaymentOrTrade {
  final num price;
  final User from;
  final DateTime date;
  final String? description;

  const PaymentOrTrade({
    required this.price,
    required this.from,
    required this.date,
    required this.description,
  });
}
