import 'package:house_wallet/data/payments/payment.dart';
import 'package:house_wallet/data/payments/trade.dart';
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

  Map<String, int> get shares => this is PaymentRef ? (this as PaymentRef).to.map((key, value) => MapEntry(key, value.share)) : {(this as TradeRef).to.uid: 1};
}
