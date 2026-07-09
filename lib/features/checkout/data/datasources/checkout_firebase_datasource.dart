import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/firebase/firebase_functions_gateway.dart';
import '../../domain/entities/place_order_result_entity.dart';
import '../utils/place_order_exception_mapper.dart';
import 'checkout_data_source.dart';

class CheckoutFirebaseDataSource implements CheckoutDataSource {
  CheckoutFirebaseDataSource(this._functionsGateway);

  final FirebaseFunctionsGateway _functionsGateway;

  @override
  Future<PlaceOrderResultEntity> placeOrder(Map<String, dynamic> payload) async {
    try {
      debugPrint(
        '[Checkout] CF call placeOrder '
        'customerType=${payload['customerType']} '
        'userId=${payload['userId']} '
        'payment=${payload['paymentMethod']}',
      );
      final data = await _functionsGateway.call('placeOrder', payload);
      final result = PlaceOrderResultEntity.fromMap(data);
      if (result.orderId.isEmpty) {
        throw const ServerFailure(
          message: PlaceOrderExceptionMapper.defaultMessage,
          code: 'INVALID_RESPONSE',
        );
      }
      return result;
    } on FirebaseFunctionsException catch (error) {
      debugPrint(
        '[Checkout] CF exception code=${error.code} message=${error.message}',
      );
      throw ServerFailure(
        message: error.message ?? PlaceOrderExceptionMapper.defaultMessage,
        code: _resolveCode(error),
      );
    } on Failure {
      rethrow;
    } catch (error) {
      debugPrint('[Checkout] CF unexpected: $error');
      throw ServerFailure(
        message: PlaceOrderExceptionMapper.defaultMessage,
        code: PlaceOrderExceptionMapper.extractErrorCode(error),
      );
    }
  }

  String? _resolveCode(FirebaseFunctionsException error) {
    final details = error.details;
    if (details is Map) {
      final code = details['code'] ?? details['errorCode'];
      if (code != null && code.toString().trim().isNotEmpty) {
        return code.toString().toUpperCase();
      }
    }

    return switch (error.code) {
      'unauthenticated' => 'UNAUTHENTICATED',
      // Do not collapse every permission-denied into login — e.g. AUTH_USER_MISMATCH.
      'permission-denied' =>
          _codeFromMessage(error.message) ?? 'PERMISSION_DENIED',
      'resource-exhausted' => 'RATE_LIMITED',
      'failed-precondition' => _codeFromMessage(error.message),
      'invalid-argument' =>
          _codeFromMessage(error.message) ?? 'INVALID_ARGUMENT',
      _ => _codeFromMessage(error.message) ??
          PlaceOrderExceptionMapper.extractErrorCode(error),
    };
  }

  String? _codeFromMessage(String? message) {
    if (message == null) {
      return null;
    }
    final upper = message.toUpperCase();
    for (final code in [
      'OUT_OF_STOCK',
      'PRICE_MISMATCH',
      'TERMS_REQUIRED',
      'AUTH_USER_MISMATCH',
      'INVALID_PAYMENT_METHOD',
      'INVALID_CUSTOMER',
      'INVALID_ITEMS',
      'UNAUTHENTICATED',
      'RATE_LIMITED',
    ]) {
      if (upper.contains(code)) {
        return code;
      }
    }
    return null;
  }
}
