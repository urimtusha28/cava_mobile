import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/presentation/result_extensions.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/usecases/address_usecases.dart';
import '../../domain/usecases/is_logged_in.dart';

class AddressesController extends BaseController {
  AddressesController(
    this._isLoggedIn,
    this._getAddresses,
    this._addAddress,
    this._setDefaultAddress,
  );

  final IsLoggedInUseCase _isLoggedIn;
  final GetAddressesUseCase _getAddresses;
  final AddAddressUseCase _addAddress;
  final SetDefaultAddressUseCase _setDefaultAddress;

  List<AddressEntity> addresses = const [];
  bool requiresLogin = false;
  bool actionLoading = false;
  String? actionError;

  Future<void> load() {
    return runLoad(() async {
      await _refreshAddresses();
    });
  }

  Future<Result<void>> addAddress(AddAddressParams params) async {
    return _runAction(() => _addAddress(params));
  }

  Future<void> setDefault(String addressId) {
    return runAction(() async {
      await unwrapFutureResult(
        _setDefaultAddress(SetDefaultAddressParams(addressId: addressId)),
        fallback: null,
      );
      await _refreshAddresses();
    });
  }

  Future<Result<void>> _runAction(Future<Result<void>> Function() action) async {
    actionLoading = true;
    actionError = null;
    notifyListeners();

    final result = await action();

    actionLoading = false;
    actionError = result.failureOrNull?.message;
    notifyListeners();

    if (result.isSuccess) {
      await _refreshAddresses();
    }
    return result;
  }

  Future<void> _refreshAddresses() async {
    final loggedIn = await unwrapFutureResult(
      _isLoggedIn(),
      fallback: false,
    );
    requiresLogin = !loggedIn;
    if (!loggedIn) {
      addresses = const [];
      notifyListeners();
      return;
    }

    addresses = await unwrapFutureResult(
      _getAddresses(),
      fallback: const [],
    );
    notifyListeners();
  }
}

AddressesController createAddressesController() {
  configureDependencies();
  return sl<AddressesController>();
}
