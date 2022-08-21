import 'package:reach_auth/reach_auth.dart';
import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

final messagesStreamPvdr = StreamProvider.family<dynamic, String?>(
  ((ref, chatId) => ref.read(chatsRepoPvdr).streamMessages(chatId ?? "")),
);

final chatsStreamPvdr = StreamProvider<List<Chat>>(
  ((ref) {
    final userId = ref.watch(userPvdr).value?.uid ?? "";
    final chatsRepo = ref.watch(chatsRepoPvdr);
    return chatsRepo.streamChats(userId);
  }),
);
