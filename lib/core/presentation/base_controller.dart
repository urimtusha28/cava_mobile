import 'package:flutter/foundation.dart';

/// Base [ChangeNotifier] for feature controllers/view models.
abstract class BaseController extends ChangeNotifier {
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  @protected
  Future<void> runLoad(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      _isInitialized = true;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @protected
  Future<void> runAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      _errorMessage = error.toString();
    }
    notifyListeners();
  }
}
