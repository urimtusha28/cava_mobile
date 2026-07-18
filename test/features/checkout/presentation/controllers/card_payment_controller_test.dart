import 'package:cava_ecommerce/core/di/injection.dart';
import 'package:cava_ecommerce/core/error/failures.dart';
import 'package:cava_ecommerce/core/state/cart_state_notifier.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/add_to_cart.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/clear_cart.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/get_cart_items.dart';
import 'package:cava_ecommerce/features/cart/presentation/controllers/cart_controller.dart';
import 'package:cava_ecommerce/features/checkout/data/local/pending_card_payment_storage.dart';
import 'package:cava_ecommerce/features/checkout/domain/entities/place_order_result_entity.dart';
import 'package:cava_ecommerce/features/checkout/domain/entities/quipu_payment_entities.dart';
import 'package:cava_ecommerce/features/checkout/domain/repositories/quipu_payment_repository.dart';
import 'package:cava_ecommerce/features/checkout/domain/utils/quipu_hpp_navigation_policy.dart';
import 'package:cava_ecommerce/features/checkout/domain/usecases/initiate_quipu_payment.dart';
import 'package:cava_ecommerce/features/checkout/domain/usecases/verify_quipu_payment.dart';
import 'package:cava_ecommerce/features/checkout/presentation/controllers/card_payment_controller.dart';
import 'package:cava_ecommerce/features/products/data/mock/mock_products.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/test_di.dart';

class _FakeQuipuRepository implements QuipuPaymentRepository {
  bool verifiedPaid = false;
  String? gatewayStatus;
  Failure? initiateFailure;
  Failure? verifyFailure;

  int initiateCalls = 0;
  int verifyCalls = 0;

  @override
  Future<QuipuInitiateResultEntity> initiatePayment({
    required String cavaOrderId,
    String? language,
  }) async {
    initiateCalls++;
    final failure = initiateFailure;
    if (failure != null) {
      throw failure;
    }
    return QuipuInitiateResultEntity(
      redirectUrl: 'https://hpp.example/pay?id=q-$cavaOrderId&password=p',
      quipuOrderId: 'q-$cavaOrderId',
      status: 'redirect_issued',
      transactionId: 'tx-$cavaOrderId',
    );
  }

  @override
  Future<QuipuVerifyResultEntity> verifyPayment(String transactionId) async {
    verifyCalls++;
    final failure = verifyFailure;
    if (failure != null) {
      throw failure;
    }
    return QuipuVerifyResultEntity(
      transactionId: transactionId,
      cavaOrderId: 'order-1',
      gatewayStatus: gatewayStatus,
      verifiedPaid: verifiedPaid,
    );
  }
}

const _order = PlaceOrderResultEntity(
  orderId: 'order-1',
  orderNumber: 'CP-1001',
  total: 57,
  paymentMethod: 'stripe',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeQuipuRepository quipuRepository;
  late CardPaymentController controller;
  late PendingCardPaymentStorage storage;

  Future<int> cartItemCount() async {
    final items = await sl<GetCartItemsUseCase>()();
    return items.dataOrNull?.length ?? 0;
  }

  Future<void> configure() async {
    await setUpTestDependencies();
    CartStateNotifier.reset();
    quipuRepository = _FakeQuipuRepository();
    storage = PendingCardPaymentStorage();

    await sl<AddToCartUseCase>()(
      AddToCartParams(product: MockProducts.products.first, quantity: 1),
    );

    final cartController = sl<CartController>();
    await cartController.load();

    controller = CardPaymentController(
      InitiateQuipuPaymentUseCase(quipuRepository),
      VerifyQuipuPaymentUseCase(quipuRepository),
      sl<ClearCartUseCase>(),
      cartController,
      storage,
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await configure();
  });

  tearDown(() async {
    await tearDownTestDependencies();
  });

  test(
    'start issues redirect, persists pending payment, awaits payment',
    () async {
      final url = await controller.start(_order);

      expect(url, contains('https://hpp.example/pay'));
      expect(controller.phase, CardPaymentPhase.awaitingPayment);
      expect(controller.transactionId, 'tx-order-1');
      expect(quipuRepository.initiateCalls, 1);

      final pending = await storage.read();
      expect(pending?.orderId, 'order-1');
      expect(pending?.transactionId, 'tx-order-1');
    },
  );

  test('start is idempotent for the same order (double-tap guard)', () async {
    final first = await controller.start(_order);
    final second = await controller.start(_order);

    expect(second, first);
    expect(quipuRepository.initiateCalls, 1);
  });

  test('start failure maps to error phase and keeps cart', () async {
    quipuRepository.initiateFailure = const ServerFailure(
      message: 'ORDER_ALREADY_PAID',
      code: 'ORDER_ALREADY_PAID',
    );

    final url = await controller.start(_order);

    expect(url, isNull);
    expect(controller.phase, CardPaymentPhase.error);
    expect(controller.failureCode, 'ORDER_ALREADY_PAID');
    expect(await cartItemCount(), 1);
  });

  test('verifyNow with verifiedPaid clears cart and pending storage', () async {
    await controller.start(_order);
    quipuRepository.verifiedPaid = true;
    quipuRepository.gatewayStatus = 'paid';

    await controller.verifyNow();

    expect(controller.phase, CardPaymentPhase.paid);
    expect(await cartItemCount(), 0);
    expect(await storage.read(), isNull);
  });

  test('verifyNow unverified keeps cart and pending storage', () async {
    await controller.start(_order);
    quipuRepository.verifiedPaid = false;
    quipuRepository.gatewayStatus = 'created';

    await controller.verifyNow();

    expect(controller.phase, CardPaymentPhase.pending);
    expect(await cartItemCount(), 1);
    expect(await storage.read(), isNotNull);
  });

  test('gateway cancelled/expired/failed map to their phases without touching '
      'the cart', () async {
    await controller.start(_order);

    quipuRepository.gatewayStatus = 'cancelled';
    await controller.verifyNow();
    expect(controller.phase, CardPaymentPhase.cancelled);

    quipuRepository.gatewayStatus = 'expired';
    await controller.verifyNow();
    expect(controller.phase, CardPaymentPhase.expired);

    quipuRepository.gatewayStatus = 'declined';
    await controller.verifyNow();
    expect(controller.phase, CardPaymentPhase.failed);

    expect(await cartItemCount(), 1);
  });

  test('verify error is retryable and keeps cart', () async {
    await controller.start(_order);
    quipuRepository.verifyFailure = const ServerFailure(
      message: 'network',
      code: 'QUIPU_VERIFY_FAILED',
    );

    await controller.verifyNow();

    expect(controller.phase, CardPaymentPhase.error);
    expect(controller.canVerify, isTrue);
    expect(await cartItemCount(), 1);

    quipuRepository.verifyFailure = null;
    quipuRepository.verifiedPaid = true;
    await controller.verifyNow();
    expect(controller.phase, CardPaymentPhase.paid);
  });

  test('onAppResumed verifies only while awaiting payment', () async {
    await controller.onAppResumed();
    expect(quipuRepository.verifyCalls, 0);

    await controller.start(_order);
    quipuRepository.verifiedPaid = true;
    await controller.onAppResumed();

    expect(quipuRepository.verifyCalls, 1);
    expect(controller.phase, CardPaymentPhase.paid);
  });

  test('verifyNow after paid does not call backend again', () async {
    await controller.start(_order);
    quipuRepository.verifiedPaid = true;
    await controller.verifyNow();
    expect(controller.phase, CardPaymentPhase.paid);

    await controller.verifyNow();
    expect(quipuRepository.verifyCalls, 1);
  });

  test('in-app WebView return flow: intercepted return URL matches the stored '
      'transaction and server verification settles the payment', () async {
    await controller.start(_order);

    // The backend appends the transaction id to the HPP return URL; the
    // WebView intercepts that URL instead of loading it.
    final returnUrl =
        'https://cava-premium.com/payment/return'
        '?transactionId=${controller.transactionId}';
    final decision = QuipuHppNavigationPolicy.decide(returnUrl);

    expect(decision.action, HppNavigationAction.interceptReturn);
    expect(decision.transactionId, controller.transactionId);

    // Reaching the return URL is NOT success — verification still decides.
    quipuRepository.verifiedPaid = false;
    quipuRepository.gatewayStatus = 'created';
    await controller.verifyNow();
    expect(controller.phase, CardPaymentPhase.pending);
    expect(await cartItemCount(), 1);

    quipuRepository.verifiedPaid = true;
    await controller.verifyNow();
    expect(controller.phase, CardPaymentPhase.paid);
    expect(await cartItemCount(), 0);
  });

  test('restorePending resumes a persisted in-flight payment', () async {
    await storage.write(
      const PendingCardPayment(
        orderId: 'order-1',
        transactionId: 'tx-order-1',
        orderNumber: 'CP-1001',
        total: 57,
      ),
    );

    final restored = await controller.restorePending();

    expect(restored, isTrue);
    expect(controller.transactionId, 'tx-order-1');
    expect(controller.phase, CardPaymentPhase.awaitingPayment);
    expect(controller.order?.orderId, 'order-1');
  });
}
