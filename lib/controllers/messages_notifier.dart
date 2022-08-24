import 'package:reach_chats/models/models.dart';
import 'package:reach_chats/providers/providers.dart';
import 'package:reach_chats/repositories/chats_repository.dart';
import 'package:reach_core/core/core.dart';

class MessagesNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  final ChatsRepository _repository;

  List<Message> get messages => state.value!;

  MessagesNotifier(AsyncValue<List<Message>> messages, this._repository)
      : super(const AsyncLoading()) {
    messages.when(
        data: (messages) => state = AsyncData(messages),
        error: (e, t) => AsyncError(e),
        loading: () => state = const AsyncLoading());
  }
}

final messagesPvdr =
    StateNotifierProvider<MessagesNotifier, AsyncValue<List<Message>>>(
  (ref) => MessagesNotifier(
    ref.watch(
      messagesStreamPvdr(
        ref.watch(
          chatIdPvdr,
        ),
      ),
    ),
    ref.watch(
      chatsRepoPvdr,
    ),
  ),
);
