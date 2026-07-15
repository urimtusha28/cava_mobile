import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../../../notifications/domain/entities/notification_type.dart';
import '../../../notifications/domain/repositories/notifications_repository.dart';

class AdminCreateNotificationParams {
  const AdminCreateNotificationParams({
    required this.recipientUid,
    required this.title,
    required this.body,
    required this.type,
  });

  final String recipientUid;
  final String title;
  final String body;
  final NotificationType type;
}

class AdminCreateNotificationUseCase
    extends BaseUseCase<void, AdminCreateNotificationParams> {
  AdminCreateNotificationUseCase(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<Result<void>> call(AdminCreateNotificationParams params) async {
    final uid = params.recipientUid.trim();
    final title = params.title.trim();
    final body = params.body.trim();
    if (uid.isEmpty || title.isEmpty || body.isEmpty) {
      return const Error(
        ValidationFailure(message: 'Plotëso titullin, tekstin dhe UID.'),
      );
    }
    if (params.type != NotificationType.promotion &&
        params.type != NotificationType.general) {
      return const Error(
        ValidationFailure(
          message: 'Lloji duhet të jetë promotion ose general.',
        ),
      );
    }
    return guard(
      () => _repository.createNotificationForUser(
        recipientUid: uid,
        title: title,
        body: body,
        type: params.type,
      ),
    );
  }
}
