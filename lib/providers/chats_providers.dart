import 'package:reach_auth/reach_auth.dart';
import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

final messagesStreamPvdr = StreamProvider.family<List<Message>, String?>(
  ((ref, chatId) => ref.read(chatsRepoPvdr).streamMessages(chatId ?? "")),
);

final chatsStreamPvdr = StreamProvider<List<Chat>>(
  ((ref) {
    final userId = ref.watch(userIdPvdr);

    return ref.read(chatsRepoPvdr).streamChats(userId);
  }),
);

final openedChatPvdr = StateProvider<Chat>(((ref) => PeerChat.empty()));
