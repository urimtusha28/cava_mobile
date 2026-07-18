enum FulfillmentStatusDetail {
  received,
  confirmed,
  prepared,
  shipped,
  inTransit,
  delivered,
  returned,
  canceled,
}

extension FulfillmentStatusDetailX on FulfillmentStatusDetail {
  String get rawValue => switch (this) {
        FulfillmentStatusDetail.received => 'received',
        FulfillmentStatusDetail.confirmed => 'confirmed',
        FulfillmentStatusDetail.prepared => 'prepared',
        FulfillmentStatusDetail.shipped => 'shipped',
        FulfillmentStatusDetail.inTransit => 'in_transit',
        FulfillmentStatusDetail.delivered => 'delivered',
        FulfillmentStatusDetail.returned => 'returned',
        FulfillmentStatusDetail.canceled => 'canceled',
      };

  bool get isTerminal =>
      this == FulfillmentStatusDetail.returned ||
      this == FulfillmentStatusDetail.canceled;

  String get albanianLabel => switch (this) {
        FulfillmentStatusDetail.received => 'Porosia u pranua',
        FulfillmentStatusDetail.confirmed => 'U konfirmua',
        FulfillmentStatusDetail.prepared => 'U përgatit',
        FulfillmentStatusDetail.shipped => 'U dërgua te postieri',
        FulfillmentStatusDetail.inTransit => 'Në transport',
        FulfillmentStatusDetail.delivered => 'U dorëzua',
        FulfillmentStatusDetail.returned => 'Kthyer / Return',
        FulfillmentStatusDetail.canceled => 'Anuluar',
      };
}

const List<FulfillmentStatusDetail> fulfillmentStatusDetailValues = [
  FulfillmentStatusDetail.received,
  FulfillmentStatusDetail.confirmed,
  FulfillmentStatusDetail.prepared,
  FulfillmentStatusDetail.shipped,
  FulfillmentStatusDetail.inTransit,
  FulfillmentStatusDetail.delivered,
  FulfillmentStatusDetail.returned,
  FulfillmentStatusDetail.canceled,
];
