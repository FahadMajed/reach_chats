import 'package:get/get.dart';
import 'package:reach_auth/providers/auth_providers.dart';
import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';
import 'package:reach_research/models/group.dart';

class ChatsListNotifier extends StateNotifier<List<Chat>> {
  final ChatsRepository _repository;
  final List<Chat> _chats;

  ChatsListNotifier(
    this._repository,
    this._chats,
  ) : super([]) {
    state = _chats;
  }

  Future<void> createGroupChat({
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
        'researcher': researcher,
        'participants': participants,
        'groupName': groupName,
        'membersIds': membersIds,
        'lastMessage': "",
        'lastMessageDate': Timestamp.now(),
        'dateOpenedByMembers': dateOpenedByMembers,
        'color': ColorGenerator.getRandomColor().value,
        'isLastMessageSeen': 1,
        'lastMessageSenderId': researcher.researcherId,
        'sinceLastMessage': DateTime.now().difference(DateTime.now()),
      },
    );

    await _repository.create(groupChat, groupId);
  }

  Future<PeerChat> createPeerChat(
    String chatId,
    Researcher researcher,
    Participant participant,
    String researchId,
  ) async {
    PeerChat peerChat = PeerChat(
      {
        'chatId': chatId,
        'researcher': researcher,
        'lastMessageDate': Timestamp.now(),
        'dateOpenedByMembers': {
          researcher.researcherId: Timestamp.now(),
          participant.participantId: Timestamp.now(),
        },
        'researchsInCommon': [researchId],
        'participant': participant,
        'membersIds': [researcher.researcherId, participant.participantId],
        'lastMessage': "",
        'isLastMessageSeen': 1,
        'lastMessageSenderId': "",
        'sinceLastMessage': DateTime.now().difference(DateTime.now()),
      },
    );

    fcm.subscribeToTopic(researcher.researcherId + participant.participantId);

    await _repository.create(peerChat, chatId);
    return peerChat;
  }

  void sendMessage(String chatId, Message message) =>
      _repository.createMessage(chatId, message);

  bool chatExists(String chatId) =>
      _chats.indexWhere((c) => c.chatId == chatId) != -1;

  Chat? getChat(String chatId) =>
      chatExists(chatId) ? _chats.firstWhere((c) => c.chatId == chatId) : null;

  Future<void> removeParticipantChatsFromResearch(
    String participantId,
    String researchId,
  ) async {
    for (final chat in _chats) {
      if (chatIsInResearch(chat, participantId, researchId)) {
        if (chat is PeerChat) {
          removeResearchIdFromChat(chat.chatId, researchId);
        } else {
          _removeFromGroupChat(chat.chatId, participantId);
        }
      }
    }
  }

  bool removeResearchIdFromChat(String chatId, String researchId) {
    if (chatExists(chatId) == false) return false;
    _repository.removeResearchIdFromChat(chatId, researchId);
    return true;
  }

  ///for group chats
  Future<bool> _removeFromGroupChat(String chatId, String participantId) async {
    if (chatExists(chatId) == false) {
      return false;
    } else {
      final chat = getChat(chatId) as GroupChat;
      chat.removeMember(participantId);
      await updateChat(chat);
      return true;
    }
  }

  Future<void> changeParticipantGroup(
    Participant participant, {
    required String fromId,
    required String toId,
  }) async {
    //remove from group first
    if (chatExists(fromId)) {
      await _removeFromGroupChat(fromId, participant.participantId);
    }
    //then add to group
    if (chatExists(toId)) {
      await addToGroupChat(toId, participant);
    }
  }

  Future<void> addToGroupChat(String toId, Participant participant) async {
    final chat = getChat(toId) as GroupChat;
    chat.addMember(participant);
    await updateChat(chat);
  }

  List<Chat> chatsForResearch(researchId) =>
      _chats.where((c) => c.researchsInCommon.contains(researchId)).toList();

  List<Chat> groupChatsForResearch(researchId) => _chats
      .where(
        (c) => c.researchsInCommon.contains(researchId) && c is GroupChat,
      )
      .toList();

  bool chatIsInResearch(Chat chat, participantId, researchId) =>
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

          await updateChat(chat);
        }
      }
    }
  }

  Future<void> updateResearcher(researcher) async {
    for (final chat in _chats) {
      await _repository.updateData(
          copyChatWith(chat, researcher: researcher), chat.chatId);
    }
  }

  Future<void> updateParticipantData(researcher) async {
    for (final chat in _chats) {
      await _repository.updateData(
          copyChatWith(chat, researcher: researcher), chat.chatId);
    }
  }

  Future<void> addResearchIdToChats(
    List participantsIds,
    String researchId,
    String researcherId,
  ) async {
    for (final participantId in participantsIds) {
      final chatId = Formatter.formatChatId(researcherId, participantId);
      if (chatExists(chatId)) {
        await _repository.addResearchIdToChats(chatId, researchId);
      }
    }
  }

  Future<void> addResearchIdToChat(
    String participantId,
    String researchId,
    String researcherId,
  ) async {
    final chatId = Formatter.formatChatId(researcherId, participantId);
    if (chatExists(chatId)) {
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
      if (chatExists(chatId)) {
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

    if (chatExists(chatId)) {
      final chat = getChat(chatId);
      Get.to(ChatScreen(chat!));
    } else {
      await createPeerChat(
        chatId,
        researcher,
        participant,
        researchId,
      ).then((chat) => Get.to(ChatScreen(chat)));
    }
  }

  Future<void> updateChat(Chat chat) async =>
      await _repository.updateData(chat, chat.chatId);
}

final chatsPvdr = StateNotifierProvider<ChatsListNotifier, List<Chat>>(
  (ref) {
    List<Chat> chats = [];
    final userId = ref.watch(userPvdr).value?.uid ?? "";

    if (userId.isNotEmpty) {
      ref.watch(chatsStreamPvdr).when(
            data: (value) => chats = value,
            error: (e, t) => throw (e),
            loading: () => chats = [],
          );
    }
    return ChatsListNotifier(
      ref.read(chatsRepoPvdr),
      chats,
    );
  },
);
