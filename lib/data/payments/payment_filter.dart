class PaymentFilter {
  Set<String>? categoryId;
  Set<String>? fromUser;
  Set<String>? toUser;
  bool? andOr;
  DateTime? fromDate;
  DateTime? toDate;
  num? minAmount;
  num? maxAmount;
  String? shouldMatch;
  String? titleShouldMatch;
  String? descriptionShouldMatch; //TODO non ricordo perchè lo avessi messo

  PaymentFilter({
    this.categoryId,
    this.fromUser,
    this.toUser,
    this.fromDate,
    this.toDate,
    this.minAmount,
    this.maxAmount,
    this.shouldMatch,
    this.titleShouldMatch,
    this.descriptionShouldMatch,
  });
}
