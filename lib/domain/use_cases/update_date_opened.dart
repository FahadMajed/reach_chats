import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

class UpdateChatDateOpened extends UseCase<void, UpdateChatDateOpenedRequest> {
  final ChatsRepository repository;
  UpdateChatDateOpened(this.repository);
  @override
  Future<void> call(UpdateChatDateOpenedRequest request) async {
    await repository.updateDateOpened(request.chatId, request.userId);
  }
}

class UpdateChatDateOpenedRequest {
  final String userId;
  final String chatId;
  UpdateChatDateOpenedRequest({
    required this.userId,
    required this.chatId,
  });
}

final updateChatDateOpenedPvdr = Provider<UpdateChatDateOpened>((ref) => UpdateChatDateOpened(
      ref.read(chatsRepoPvdr),
    ));
