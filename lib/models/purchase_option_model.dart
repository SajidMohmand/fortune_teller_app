
class PurchaseOption {
  final String title;
  final double price;
  final String description;
  final int questionCount;
  final String? badge;
  final int? savingsPercent;

  PurchaseOption({
    required this.title,
    required this.price,
    required this.description,
    required this.questionCount,
    this.badge,
    this.savingsPercent,
  });
}
