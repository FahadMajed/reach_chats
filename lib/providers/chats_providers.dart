import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reach_auth/reach_auth.dart';
import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

final chatsRepoPvdr = Provider(
  (ref) => ChatsRepository(
    ref.read(databaseProvider),
  ),
);

final messagesStreamPvdr = StreamProvider.family<dynamic, String?>(
  ((ref, chatId) => ref.read(chatsRepoPvdr).streamSubCollection(chatId ?? "")),
);

final _chatsStreamPvdr = StreamProvider<List<Chat>>(
  ((ref) {
    final userId = ref.watch(userPvdr).value?.uid ?? "";
    final chatsRepo = ref.watch(chatsRepoPvdr);
    return chatsRepo.streamDocuments(userId);
  }),
);

final chatsPvdr = StateNotifierProvider<ChatsListNotifier, List<Chat>>((ref) {
  List<Chat> chats = [];
  final userId = ref.watch(userPvdr).value?.uid ?? "";

  if (userId.isNotEmpty) {
    ref.watch(_chatsStreamPvdr).when(
          data: (value) => chats = value,
          error: (e, t) => throw (e),
          loading: () => chats = [],
        );
  }
  return ChatsListNotifier(
    reader: ref.read,
    uid: userId,
    chats: chats,
  );
});
