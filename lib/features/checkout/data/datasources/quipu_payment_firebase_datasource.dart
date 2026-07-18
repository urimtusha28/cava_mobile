import 'dart:io' show Platform;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/firebase/firebase_functions_gateway.dart';
import '../../domain/entities/quipu_payment_entities.dart';
import 'quipu_payment_data_source.dart';

/// Calls the existing website backend callables (`initiateQuipuPayment`,
/// `verifyQuipuPayment`). No Quipu secret, merchant certificate, or card data
/// ever exists on the device — the amount is read server-side from the order.
class QuipuPaymentFirebaseDataSource implements QuipuPaymentDataSource {
  QuipuPaymentFirebaseDataSource(this._functionsGateway);

  final FirebaseFunctionsGateway _functionsGateway;

  @override
  Future<QuipuInitiateResultEntity> initiatePayment({
    required String cavaOrderId,
    String? language,
  }) async {
    try {
      final data = await _functionsGateway.call('initiateQuipuPayment', {
        'cavaOrderId': cavaOrderId,
        if (language != null && language.trim().isNotEmpty)
          'language': language.trim(),
        // Server-side sanitizeBrowserMeta fills sandbox-safe defaults for any
        // missing fields and derives the real client IP itself.
        'browser': _mobileBrowserMeta(),
      });
      final result = QuipuInitiateResultEntity.fromMap(data);
      if (!result.isValid) {
        throw const ServerFailure(
          message: 'Pagesa nuk mund të inicohej.',
          code: 'QUIPU_INVALID_INITIATE_RESPONSE',
        );
      }
      return result;
    } on FirebaseFunctionsException catch (error) {
      debugPrint(
        '[Quipu] initiate exception code=${error.code} '
        'message=${error.message}',
      );
      throw ServerFailure(
        message: error.message ?? 'Pagesa nuk mund të inicohej.',
        code: _quipuErrorCode(error) ?? 'QUIPU_INITIATE_FAILED',
      );
    } on Failure {
      rethrow;
    } catch (error) {
      debugPrint('[Quipu] initiate unexpected: $error');
      throw const ServerFailure(
        message: 'Pagesa nuk mund të inicohej.',
        code: 'QUIPU_INITIATE_FAILED',
      );
    }
  }

  @override
  Future<QuipuVerifyResultEntity> verifyPayment(String transactionId) async {
    try {
      final data = await _functionsGateway.call('verifyQuipuPayment', {
        'transactionId': transactionId,
      });
      return QuipuVerifyResultEntity.fromMap(data);
    } on FirebaseFunctionsException catch (error) {
      debugPrint(
        '[Quipu] verify exception code=${error.code} '
        'message=${error.message}',
      );
      throw ServerFailure(
        message: error.message ?? 'Verifikimi i pagesës dështoi.',
        code: _quipuErrorCode(error) ?? 'QUIPU_VERIFY_FAILED',
      );
    } on Failure {
      rethrow;
    } catch (error) {
      debugPrint('[Quipu] verify unexpected: $error');
      throw const ServerFailure(
        message: 'Verifikimi i pagesës dështoi.',
        code: 'QUIPU_VERIFY_FAILED',
      );
    }
  }

  Map<String, dynamic> _mobileBrowserMeta() {
    return {
      'javaEnabled': false,
      'jsEnabled': true,
      'tzOffset': '${DateTime.now().timeZoneOffset.inMinutes * -1}',
      'language': Platform.localeName.replaceAll('_', '-'),
      'userAgent': 'CavaMobile (${Platform.operatingSystem})',
    };
  }

  static const _knownCodes = [
    'ORDER_NOT_FOUND',
    'ORDER_OWNER_MISMATCH',
    'ORDER_ALREADY_PAID',
    'INVALID_ORDER_ID',
    'INVALID_ORDER_AMOUNT',
    'INVALID_TRANSACTION_ID',
    'TRANSACTION_NOT_FOUND',
    'TRANSACTION_NOT_INITIATED',
    'QUIPU_CREATE_ORDER_FAILED',
    'QUIPU_REQUEST_ERROR',
    'QUIPU_UNSUPPORTED_ENV',
  ];

  String? _quipuErrorCode(FirebaseFunctionsException error) {
    final message = error.message?.toUpperCase() ?? '';
    for (final code in _knownCodes) {
      if (message.contains(code)) {
        return code;
      }
    }
    return null;
  }
}
