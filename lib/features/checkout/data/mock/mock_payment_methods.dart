import '../../domain/entities/payment_method_entity.dart';

abstract final class MockPaymentMethods {
  static const List<PaymentMethodEntity> methods = [
    PaymentMethodEntity(
      id: 'pay-card',
      type: PaymentMethodType.card,
      title: 'Paguaj me Kartë (Quipu)',
      subtitle: 'Paguaj online në mënyrë të sigurt',
      iconName: 'credit_card',
    ),
    PaymentMethodEntity(
      id: 'pay-bank',
      type: PaymentMethodType.bankTransfer,
      title: 'Transfer Bankar',
      subtitle: 'Do të konfirmohet manualisht',
      iconName: 'account_balance',
    ),
    PaymentMethodEntity(
      id: 'pay-cash',
      type: PaymentMethodType.cashOnDelivery,
      title: 'Pagesë në dorëzim (Cash)',
      subtitle: 'Paguaj kur të pranosh porosinë',
      iconName: 'payments',
    ),
  ];
}
