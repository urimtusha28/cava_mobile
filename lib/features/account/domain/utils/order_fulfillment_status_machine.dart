import '../entities/order_fulfillment_status.dart';

FulfillmentStatusDetail normalizeFulfillmentForTransitions(String raw) {
  final lower = raw.trim().toLowerCase();
  if (lower == 'fulfilled') {
    return FulfillmentStatusDetail.delivered;
  }

  for (final value in fulfillmentStatusDetailValues) {
    if (value.rawValue == lower) {
      return value;
    }
  }

  return FulfillmentStatusDetail.received;
}

void assertAllowedFulfillmentTransition(
  FulfillmentStatusDetail from,
  FulfillmentStatusDetail to,
) {
  if (from.isTerminal) {
    throw StateError(
      'Nuk lejohet ndryshimi i statusit nga ${from.rawValue} (status terminal).',
    );
  }
  if (!fulfillmentStatusDetailValues.contains(to)) {
    throw StateError('Status i pavlefshëm: ${to.rawValue}');
  }
}

List<FulfillmentStatusDetail> allowedStatusesForCurrent(String rawCurrent) {
  final current = normalizeFulfillmentForTransitions(rawCurrent);
  if (current.isTerminal) {
    return [current];
  }
  return List<FulfillmentStatusDetail>.unmodifiable(
    fulfillmentStatusDetailValues,
  );
}
