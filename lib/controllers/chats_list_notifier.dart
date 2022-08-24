import 'package:get/get.dart';
import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';
import 'package:reach_research/models/group.dart';

class ChatsListNotifier extends StateNotifier<AsyncValue<List<Chat>>> {
  final ChatsRepository _repository;
  late final MessagesNotifier messagesNotifier;

  List<Chat> get chats => state.value ?? [];

  ChatsListNotifier(
    this._repository,
    AsyncValue<List<Chat>> chatsAsync,
  ) : super(const AsyncLoading()) {
    chatsAsync.when(
        data: (chats) => state = AsyncData(chats),
        error: (e, t) => throw e,
        loading: () => const AsyncLoading());
  }

  Future<GroupChat> createGroupChat({
    required List<Participant> participants,
    required String groupName,
    required String researchId,
    required String groupId,
    required Researcher researcher,
  }) async {
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

    return groupChat;
  }

  Future<PeerChat> createPeerChat(
    String chatId,
    Researcher researcher,
    Participant participant, {
    String researchId = "",
  }) async {
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

//TODO FIX MESSAGING
    // fcm.subscribeToTopic(researcher.researcherId + participant.participantId);

    return await _repository.create(peerChat, chatId).then((_) => peerChat);
  }

  Future<void> sendMessage(String chatId, Message message) async {
    await _repository.createMessage(chatId, message);

    final chat = getChat(chatId)!;

    await _updateChat(
      copyChatWith(
        chat,
        lastMessageSenderId: message.fromId,
        lastMessage: message.content,
        lastMessageDate: message.timeStamp,
        dateOpenedByMembers: {
          ...chat.dateOpenedByMembers,
          message.fromId: Timestamp.now(),
        },
      ),
    );
  }

  bool _chatExists(String chatId) =>
      chats.indexWhere((c) => c.chatId == chatId) != -1;

  Chat? getChat(String chatId) =>
      _chatExists(chatId) ? chats.firstWhere((c) => c.chatId == chatId) : null;

  Future<void> removeParticipantChatsFromResearch(
    String participantId,
    String researchId,
  ) async {
    for (final chat in chats) {
      if (_chatIsInResearch(chat, participantId, researchId)) {
        if (chat is PeerChat) {
          _removeResearchIdFromChat(chat.chatId, researchId);
        } else {
          _removeFromGroupChat(chat.chatId, participantId);
        }
      }
    }
  }

  bool _removeResearchIdFromChat(String chatId, String researchId) {
    if (_chatExists(chatId) == false) return false;
    _repository.removeResearchIdFromChat(chatId, researchId);
    return true;
  }

  ///for group chats
  Future<bool> _removeFromGroupChat(String chatId, String participantId) async {
    if (_chatExists(chatId) == false) {
      return false;
    } else {
      final chat = getChat(chatId) as GroupChat;

      await _updateChat(
        copyChatWith(
          chat,
          membersIds: chat.membersIds..remove(participantId),
          dateOpenedByMembers: chat.dateOpenedByMembers..remove(participantId),
          participants: chat.participants
            ..removeWhere(
              (p) => p.participantId == participantId,
            ),
        ),
      );
      return true;
    }
  }

  Future<void> changeParticipantGroup(
    Participant participant, {
    required String fromId,
    required String toId,
  }) async {
    //remove from group first
    if (_chatExists(fromId)) {
      await _removeFromGroupChat(fromId, participant.participantId);
    }
    //then add to group
    if (_chatExists(toId)) {
      await addToGroupChat(toId, participant);
    }
  }

  Future<void> addToGroupChat(String toId, Participant participant) async {
    final chat = getChat(toId) as GroupChat;

    await _updateChat(
      copyChatWith(
        chat,
        membersIds: chat.membersIds..add(participant.participantId),
        participants: chat.participants..add(participant),
        dateOpenedByMembers: chat.dateOpenedByMembers
          ..[participant.participantId] = Timestamp.now(),
      ),
    );
  }

  List<Chat> chatsForResearch(researchId) =>
      chats.where((c) => c.researchsInCommon.contains(researchId)).toList();

  List<Chat> groupChatsForResearch(researchId) => chats
      .where(
        (c) => c.researchsInCommon.contains(researchId) && c is GroupChat,
      )
      .toList();

  bool _chatIsInResearch(Chat chat, participantId, researchId) =>
      chat.membersIds.contains(participantId) &&
      chat.researchsInCommon.contains(researchId);

  Future<void> deleteChat(String groupId) async {
    await _repository.delete(groupId);
  }

  Future<void> reorderGroups(
    List<Group> groups,
    String researchId,
    String title,
  ) async {
    for (Chat chat in groupChatsForResearch(researchId)) {
      for (final group in groups) {
        if (group.groupId == chat.chatId) {
          //reorder groups names
          chat = copyChatWith(chat, groupName: "${group.groupName} - $title");

          await _updateChat(chat);
        }
      }
    }
  }

  Future<void> updateResearcher(Researcher researcher) async {
    for (final chat in chats) {
      await _repository.updateData(
          copyChatWith(chat, researcher: researcher), chat.chatId);
    }
  }

  Future<void> updateParticipant(Participant updatedParticipant) async {
    for (final chat in chats) {
      if (chat.isGroupChat) {
        await _repository.updateData(
            copyChatWith(
              chat,
              participants: [
                for (final part in (chat as GroupChat).participants)
                  if (part.participantId == updatedParticipant.participantId)
                    updatedParticipant
                  else
                    part
              ],
            ),
            chat.chatId);
      } else {
        await _repository.updateData(
            copyChatWith(
              chat,
              participant: updatedParticipant,
            ),
            chat.chatId);
      }
    }
  }

  Future<void> addResearchIdToChats(
    List participantsIds,
    String researchId,
    String researcherId,
  ) async {
    for (final participantId in participantsIds) {
      final chatId = Formatter.formatChatId(researcherId, participantId);
      if (_chatExists(chatId)) {
        await _repository.addResearchIdToChats(chatId, researchId);
      }
    }
  }

  Future<void> addResearchIdToChat(
    String chatId,
    String researchId,
  ) async {
    if (_chatExists(chatId)) {
      await _repository.addResearchIdToChats(chatId, researchId);
    }
  }

  Future<void> sendAnnouncement({
    required List toIds,
    required String content,
    required String researcherId,
  }) async {
    final timeStamp = Timestamp.now();
    for (String chatId in toIds) {
      if (_chatExists(chatId)) {
        sendMessage(
          chatId,
          Message(
            content: content,
            timeStamp: timeStamp,
            fromId: researcherId,
            toId: chatId.contains("+") ? chatId.split("+")[1] : "all",
            messageId: timeStamp.millisecondsSinceEpoch.toString(),
          ),
        );
        final chat = getChat(chatId);

        await _repository.updateData(
            copyChatWith(
              chat!,
              dateOpenedByMembers: {
                ...chat.dateOpenedByMembers,
                chat.researcher.researcherId: Timestamp.now()
              },
              lastMessage: content,
              lastMessageDate: timeStamp,
              lastMessageSenderId: researcherId,
            ),
            chat.chatId);
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

    if (_chatExists(chatId)) {
      final chat = getChat(chatId);
      Get.to(ChatScreen(chat!));
    } else {
      await createPeerChat(
        chatId,
        researcher,
        participant,
        researchId: researchId,
      ).then((chat) => Get.to(ChatScreen(chat)));
    }
  }

  Future<void> _updateChat(Chat chat) async =>
      await _repository.updateData(chat, chat.chatId);

  Future<void> updateDateOpened(String chatId, String currentUserId) async =>
      await _repository.updateDateOpened(chatId, currentUserId);
}

final chatsPvdr =
    StateNotifierProvider<ChatsListNotifier, AsyncValue<List<Chat>>>(
  (ref) => ChatsListNotifier(
    ref.read(chatsRepoPvdr),
    ref.watch(chatsStreamPvdr),
  ),
);
