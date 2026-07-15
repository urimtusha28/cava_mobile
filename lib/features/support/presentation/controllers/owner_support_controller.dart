import 'dart:async';

import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../notifications/domain/entities/notification_type.dart';
import '../../domain/entities/support_conversation.dart';
import '../../domain/entities/support_message.dart';
import '../../domain/entities/support_status.dart';
import '../../domain/repositories/admin_support_repository.dart';
import '../../domain/usecases/admin_create_notification.dart';

class OwnerSupportController extends BaseController {
  OwnerSupportController(this._repository, this._createNotification);

  final AdminSupportRepository _repository;
  final AdminCreateNotificationUseCase _createNotification;

  List<SupportConversation> conversations = const [];
  SupportStatus? statusFilter;
  SupportConversation? selected;
  List<SupportMessage> messages = const [];
  bool isSending = false;
  String? actionError;
  String? notificationSuccess;

  StreamSubscription<List<SupportConversation>>? _listSub;
  StreamSubscription<List<SupportMessage>>? _messagesSub;

  Future<void> load({SupportStatus? filter}) {
    statusFilter = filter ?? statusFilter;
    return runLoad(() async {
      await _listSub?.cancel();
      final completer = Completer<void>();
      _listSub = _repository
          .watchConversations(statusFilter: statusFilter)
          .listen(
        (list) {
          conversations = list;
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

  void setFilter(SupportStatus? filter) {
    statusFilter = filter;
    unawaited(load(filter: filter));
  }

  Future<void> openConversation(SupportConversation conversation) async {
    selected = conversation;
    await _messagesSub?.cancel();
    _messagesSub = _repository.watchMessages(conversation.id).listen((list) {
      messages = list;
      notifyListeners();
    });
    await _repository.markReadByAdmin(conversation.id);
    notifyListeners();
  }

  Future<bool> sendReply(String text) async {
    final conv = selected;
    if (conv == null || text.trim().isEmpty || isSending) return false;
    isSending = true;
    actionError = null;
    notifyListeners();
    try {
      await _repository.sendAdminMessage(
        conversationId: conv.id,
        text: text,
      );
      isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      actionError = e.toString();
      isSending = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateStatus(SupportStatus status) async {
    final conv = selected;
    if (conv == null) return;
    await runAction(() async {
      await _repository.updateStatus(
        conversationId: conv.id,
        status: status,
      );
    });
  }

  Future<void> assignToSelf() async {
    final conv = selected;
    if (conv == null) return;
    await runAction(() => _repository.assignToSelf(conv.id));
  }

  Future<bool> sendNotification({
    required String recipientUid,
    required String title,
    required String body,
    required NotificationType type,
  }) async {
    notificationSuccess = null;
    actionError = null;
    notifyListeners();
    final result = await _createNotification(
      AdminCreateNotificationParams(
        recipientUid: recipientUid,
        title: title,
        body: body,
        type: type,
      ),
    );
    if (result.isFailure) {
      actionError = result.failureOrNull?.message ?? 'Dështoi.';
      notifyListeners();
      return false;
    }
    notificationSuccess = 'Njoftimi u dërgua.';
    notifyListeners();
    return true;
  }

  void clearChat() {
    _messagesSub?.cancel();
    _messagesSub = null;
    selected = null;
    messages = const [];
    notifyListeners();
  }

  @override
  void dispose() {
    _listSub?.cancel();
    _messagesSub?.cancel();
    super.dispose();
  }
}

OwnerSupportController createOwnerSupportController() {
  configureDependencies();
  return sl<OwnerSupportController>();
}

void unawaited(Future<void> future) {
  future.ignore();
}
