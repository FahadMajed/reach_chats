import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';
import 'package:reach_core/core/data/repositories/notifications_repository.dart';

class ChatsListNotifier extends StateNotifier<AsyncValue<List<Chat>>> {
  final ChatsRepository _repository;
  final NotificationsRepository? notificationsRepository;

  List<Chat> get chats => state.value ?? [];
  List<PeerChat> get peerChats =>
      state.value
          ?.where((c) => c is PeerChat)
          .map((c) => c as PeerChat)
          .toList() ??
      [];
  List<GroupChat> get groupChats =>
      state.value
          ?.where((c) => c is GroupChat)
          .map((c) => c as GroupChat)
          .toList() ??
      [];

  ChatsListNotifier(
    this._repository,
    this.notificationsRepository,
    AsyncValue<List<Chat>> chatsAsync,
  ) : super(const AsyncLoading()) {
    chatsAsync.when(
        data: (chats) => state = AsyncData(chats),
        error: (e, t) => throw e,
        loading: () => state = const AsyncLoading());
  }

  Future<GroupChat> createGroupChat({
    required List<Participant> participants,
    required String groupName,
    required String researchId,
    required String groupId,
    required Researcher researcher,
  }) async {
    chatsLoading();
    Map<String, dynamic> dateOpenedByMembers = {};
    final membersIds = [
      researcher.researcherId,
      for (final p in participants) p.participantId
    ];
    for (String memberId in membersIds) {
      dateOpenedByMembers[memberId] = Timestamp.now();
    }
    GroupChat groupChat = GroupChat(
      {
        'chatId': groupId,
        'researchsInCommon': [researchId],
        'researcher': researcher.toPartialMap(),
        'participants': participants.map((e) => e.toPartialMap()).toList(),
        'groupName': groupName,
        'membersIds': membersIds,
        'lastMessage': "",
        'lastMessageDate': Timestamp.now(),
        'dateOpenedByMembers': dateOpenedByMembers,
        'color': ColorGenerator.getRandomColor().value,
        'isLastMessageSeen': 1,
        'lastMessageSenderId': researcher.researcherId,
      },
    );

    await _repository.create(groupChat, groupId);
    chatsLoaded();
    return groupChat;
  }

  Future<PeerChat> createPeerChat(
    Researcher researcher,
    Participant participant, {
    String researchId = "",
  }) async {
    final chatId = Formatter.formatChatId(
      researcher.researcherId,
      participant.participantId,
    );

    PeerChat peerChat = PeerChat(
      {
        'chatId': chatId,
        'researcher': researcher.toPartialMap(),
        'lastMessageDate': Timestamp.now(),
        'dateOpenedByMembers': {
          researcher.researcherId: Timestamp.now(),
          participant.participantId: Timestamp.now(),
        },
        'researchsInCommon': researchId.isEmpty ? [] : [researchId],
        'participant': participant.toPartialMap(),
        'membersIds': [researcher.researcherId, participant.participantId],
        'lastMessage': "",
        'isLastMessageSeen': 1,
        'lastMessageSenderId': "",
      },
    );

    await notificationsRepository?.subscribeToChat(chatId);

    return await _repository.create(peerChat, chatId).then((_) => peerChat);
  }

  Future<void> sendMessage(Chat chat, Message message) async =>
      await _repository.createMessage(chat, message);

  bool _chatExists(String chatId) =>
      chats.indexWhere((c) => c.chatId == chatId) != -1;

  Chat? getChat(String chatId) =>
      _chatExists(chatId) ? chats.firstWhere((c) => c.chatId == chatId) : null;

  List<String> getPeerChatIdsForEnrollments(List enrolledIds) => peerChats
      .where((chat) => enrolledIds.contains(chat.participant.participantId))
      .map((c) => c.chatId)
      .toList();

  List<String> getPeerChatIdsForResearch(String researchId) => peerChats
      .where((chat) => chat.researchsInCommon.contains(researchId))
      .map((c) => c.chatId)
      .toList();

  ///for group chats

  List<Chat> chatsForResearch(researchId) =>
      chats.where((c) => c.researchsInCommon.contains(researchId)).toList();

  List<Chat> groupChatsForResearch(researchId) => chats
      .where(
        (c) => c.researchsInCommon.contains(researchId) && c is GroupChat,
      )
      .toList();

  Future<void> sendAnnouncement({
    required List toIds,
    required String content,
    required String researcherId,
  }) async {
    final timeStamp = Timestamp.now();
    for (String toId in toIds) {
      final chat = getChat(
        toId.contains('Group') == false
            ? Formatter.formatChatId(researcherId, toId)
            : toId,
      );
      if (chat != null) {
        sendMessage(
          chat,
          Message(
            content: content,
            timeStamp: timeStamp,
            fromId: researcherId,
            toId: toId.contains("Group") == false ? toId : "all",
            messageId: timeStamp.millisecondsSinceEpoch.toString(),
          ),
        );
      }
    }
  }

  Future<void> toPeerChat({
    required Researcher researcher,
    required Participant participant,
    required String researchId,
  }) async {
    final chatId = Formatter.formatChatId(
        researcher.researcherId, participant.participantId);
    final chat = getChat(chatId);
    if (chat != null) {
      Get.to(ChatScreen(chat));
    } else {
      chatsLoading();
      await createPeerChat(
        researcher,
        participant,
        researchId: researchId,
      ).then((chat) => Get.to(ChatScreen(chat)));
      chatsLoaded();
    }
  }

  Future<void> updateDateOpened(String chatId, String currentUserId) async =>
      await _repository.updateDateOpened(chatId, currentUserId);
}

final chatsPvdr =
    StateNotifierProvider<ChatsListNotifier, AsyncValue<List<Chat>>>(
  (ref) => ChatsListNotifier(
    ref.read(chatsRepoPvdr),
    ref.read(notificationsRepoPvdr),
    ref.watch(chatsStreamPvdr),
  ),
);

final RxBool isChatsLoading = false.obs;

void chatsLoading() => isChatsLoading.value = true;
Future<void> chatsLoaded() async => isChatsLoading.value = false;
