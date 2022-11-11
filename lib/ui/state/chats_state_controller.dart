import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

//SOURCE OF TRUTH!
class ChatsStateController extends AsyncStateControIIer<List<Chat>> {
  List<Chat> get chats => state.value ?? [];
  List<PeerChat> get peerChats => chats.whereType<PeerChat>().toList();
  List<GroupChat> get groupChats => chats.whereType<GroupChat>().toList();

  ChatsStateController(AsyncValue<List<Chat>> chatsAsync) {
    chatsAsync.when(
        data: (chats) => state = AsyncData(chats),
        error: (e, t) => throw e,
        loading: () => state = const AsyncLoading());
  }

  bool _chatExists(String chatId) => chats.indexWhere((c) => c.chatId == chatId) != -1;

  Chat? getChat(String chatId) => _chatExists(chatId) ? chats.firstWhere((c) => c.chatId == chatId) : null;

  List<String> getPeerChatIdsForEnrollments(List enrolledIds) =>
      _getPeerChatsIdsWhere((chat) => enrolledIds.contains(chat.participant.participantId));

  List<String> getPeerChatIdsForResearch(String researchId) =>
      _getPeerChatsIdsWhere((chat) => chat.researchsInCommon.contains(researchId));

  bool hasNewMessages(String userId) {
    bool hasNewMessages = false;

    for (final chat in chats) {
      if (chat.isLastMessageSeenByUser(userId) == false) {
        hasNewMessages = true;
      }
      break;
    }
    return hasNewMessages;
  }

  ///for group chats

  List<Chat> chatsForResearch(researchId) => chats.where((c) => c.researchsInCommon.contains(researchId)).toList();

  List<Chat> groupChatsForResearch(researchId) => chats
      .where(
        (c) => c.researchsInCommon.contains(researchId) && c is GroupChat,
      )
      .toList();

  // Future<void> updateDateOpened(String chatId, String currentUserId) async =>
  //     await _repository.updateDateOpened(chatId, currentUserId);

  List<String> _getPeerChatsIdsWhere(bool Function(PeerChat) clause) =>
      peerChats.where((chat) => clause(chat)).map((c) => c.chatId).toList();

  List<String> getChatsIds() => chats.map((c) => c.chatId).toList();

  GroupChat? getParticipantResearchGroupChat({
    required String researchId,
    required String participantId,
  }) =>
      groupChats.firstWhere(
        (groupChat) => groupChat.researchsInCommon.contains(researchId) && groupChat.membersIds.contains(participantId),
      );
}

final chatsStatePvdr = StateNotifierProvider<ChatsStateController, AsyncValue<List<Chat>>>(
  (ref) => ChatsStateController(
    // ref.read(chatsRepoPvdr),
    // ref.read(notificationsRepoPvdr),
    ref.watch(chatsStreamPvdr),
  ),
);

final chatsStateCtrlPvdr = Provider((ref) => ref.watch(chatsStatePvdr.notifier));
