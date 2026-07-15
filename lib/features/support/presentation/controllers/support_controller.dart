import 'dart:async';

import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../account/domain/repositories/auth_repository.dart';
import '../../domain/entities/store_contact.dart';
import '../../domain/entities/support_conversation.dart';
import '../../domain/entities/support_message.dart';
import '../../domain/repositories/support_repository.dart';

class SupportController extends BaseController {
  SupportController(this._repository, this._authRepository);

  final SupportRepository _repository;
  final AuthRepository _authRepository;

  SupportConversation? conversation;
  List<SupportMessage> messages = const [];
  StoreContact contact = StoreContact.fallback;
  bool isSending = false;
  String? sendError;

  StreamSubscription<SupportConversation?>? _conversationSub;
  StreamSubscription<List<SupportMessage>>? _messagesSub;

  Future<bool> get isLoggedIn => _authRepository.isLoggedIn();

  Future<void> load() {
    return runLoad(() async {
      contact = await _repository.getStoreContact();
      await _conversationSub?.cancel();
      final completer = Completer<void>();
      _conversationSub = _repository.watchActiveConversation().listen(
        (active) {
          conversation = active;
          if (active != null) {
            _listenMessages(active.id);
            unawaited(
              _repository.markConversationReadByCustomer(active.id),
            );
          } else {
            messages = const [];
            _messagesSub?.cancel();
            _messagesSub = null;
          }
          notifyListeners();
          if (!completer.isCompleted) completer.complete();
        },
        onError: (Object e) {
          if (!completer.isCompleted) completer.completeError(e);
        },
      );
      await completer.future.timeout(
        const Duration(seconds: 12),
        onTimeout: () {},
      );
    });
  }

  void _listenMessages(String conversationId) {
    _messagesSub?.cancel();
    _messagesSub = _repository.watchMessages(conversationId).listen((list) {
      messages = list;
      notifyListeners();
    });
  }

  Future<bool> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isSending) return false;

    final loggedIn = await _authRepository.isLoggedIn();
    if (!loggedIn) {
      sendError = 'Kyçu për të kontaktuar support-in.';
      notifyListeners();
      return false;
    }

    isSending = true;
    sendError = null;
    notifyListeners();
    try {
      final active = conversation;
      if (active == null) {
        final created = await _repository.getOrCreateActiveConversation(
          text: trimmed,
        );
        conversation = created;
        _listenMessages(created.id);
      } else {
        await _repository.sendCustomerMessage(
          conversationId: active.id,
          text: trimmed,
        );
      }
      isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      sendError = e.toString();
      isSending = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _conversationSub?.cancel();
    _messagesSub?.cancel();
    super.dispose();
  }
}

SupportController createSupportController() {
  configureDependencies();
  return sl<SupportController>();
}

void unawaited(Future<void> future) {
  future.ignore();
}
