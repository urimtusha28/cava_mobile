enum PaymentMethodType { card, bankTransfer, cashOnDelivery }

class PaymentMethodEntity {
  const PaymentMethodEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.iconName,
  });

  final String id;
  final PaymentMethodType type;
  final String title;
  final String subtitle;
  final String? iconName;
}
