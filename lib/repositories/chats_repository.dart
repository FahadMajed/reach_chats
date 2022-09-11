import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

abstract class IChatsRepository {
  Stream<List<Chat>> streamChats(String userId);

  Stream<List<Message>> streamMessages(String chatId);

  Future<void> createMessage(Chat chat, Message m);

  ///we dont want to delete the chat, just remove it
  ///from the research, in case participant was kicked
  ///from a research
  Future<void> removeResearchIdFromChat(
    String chatId,
    String researchId,
  );

  ///add research id to chat, so it chats can be
  ///filtered by research id
  Future<void> addResearchIdToPeerChat(
    String chatId,
    String researchId,
  );
}

class ChatsRepository extends BaseRepository<Chat, Message>
    implements IChatsRepository {
  ChatsRepository({required super.remoteDatabase});

  @override
  Stream<List<Chat>> streamChats(String uid) =>
      streamQuery(where("membersIds", arrayContains: uid)
          .orderBy("lastMessageDate", descending: true));

  Future<List<Chat>> fetchChats(String uid) =>
      getQuery(where("membersIds", arrayContains: uid)
          .orderBy("lastMessageDate", descending: true));

  Future<Chat?> fetchChat(String chatId) async => await get(chatId);

  Future<List<Message>> fetchMessagesForChat(String chatId) =>
      getQuerySubcollection(
        remoteDatabase
            .getSubCollection(chatId)
            .orderBy('timeStamp', descending: true)
            .limit(50),
      );

  @override
  Future<void> addResearchIdToPeerChat(
    String chatId,
    String researchId,
  ) async =>
      await updateFieldArrayUnion(chatId, 'researchsInCommon', [researchId]);

  @override
  Future<void> removeResearchIdFromChat(
          String chatId, String researchId) async =>
      await remoteDatabase.docExists(chatId)
          ? await updateFieldArrayRemove(
              chatId, 'researchsInCommon', [researchId])
          : null;

  @override
  Future<void> createMessage(Chat chat, Message message) async {
    await createSubdocument(chat.chatId, message.messageId, message);

    await remoteDatabase.updateDocumentRaw({
      'lastMessageSenderId': message.fromId,
      'lastMessage': message.content,
      'lastMessageDate': message.timeStamp,
      'dateOpenedByMembers': {
        ...chat.dateOpenedByMembers,
        message.fromId: message.timeStamp,
      },
    }, chat.chatId);
  }

  @override
  Stream<List<Message>> streamMessages(String chatId) =>
      streamSubcollectionQuery(
        remoteDatabase
            .getSubCollection(chatId)
            .orderBy('timeStamp', descending: true)
            .limit(50),
      );

  Future<void> updateDateOpened(String chatId, String currentUserId) async =>
      await updateField(
        chatId,
        'dateOpenedByMembers.$currentUserId',
        Timestamp.now(),
      );

  Future<void> updateGroupName(String groupId, String newName) async =>
      await updateField(
        groupId,
        'groupName',
        newName,
      );

  Future<void> updateParticipant(
    String chatId,
    Participant participant,
  ) async {
    final chat = await get(chatId) ?? Chat(const {});
    if (chat is GroupChat) {
      await updateData(
          copyChatWith(
            chat,
            participants: [
              for (final part in chat.participants)
                if (part.participantId == participant.participantId)
                  participant
                else
                  part,
            ],
          ),
          chatId);
    } else {
      await updateField(chatId, 'participant', participant.toPartialMap());
    }
  }

  Future<void> updateResearcher(
    String chatId,
    Researcher researcher,
  ) async =>
      await updateField(chatId, 'researcher', researcher.toPartialMap());

  Future<void> addParticipantToGroupChat(
      String groupId, Participant participant) async {
    final groupChatExists = await remoteDatabase.docExists(groupId);

    groupChatExists
        ? await remoteDatabase.updateDocumentRaw(
            {
              'participants':
                  FieldValue.arrayUnion([participant.toPartialMap()]),
              'membersIds': FieldValue.arrayUnion([participant.participantId]),
              'dateOpenedByMembers.${participant.participantId}':
                  Timestamp.now(),
            },
            groupId,
          )
        : null;
  }

  Future<void> removeParticipantFromGroupChat(
    String chatId,
    String participantId,
  ) async {
    final groupChat = await get(chatId) as GroupChat?;

    groupChat != null
        ? await remoteDatabase.updateDocumentRaw(
            {
              'participants': [
                for (final p in groupChat.participants)
                  if (p.participantId != participantId) p.toPartialMap()
              ],
              'membersIds': FieldValue.arrayRemove([participantId]),
              'dateOpenedByMembers.$participantId': FieldValue.delete(),
            },
            chatId,
          )
        : null;
  }

  Future<void> removeGroup(String groupId) async => await delete(groupId);

  Future<void> changeParticipantGroupChat(
    GroupChat? groupChatFrom,
    GroupChat? groupChatTo,
    Participant participant,
  ) async {
    final participantId = participant.participantId;
    if (groupChatFrom != null) {
      final fromUpdated = _removeParticipant(groupChatFrom, participantId);
      await updateData(fromUpdated, fromUpdated.chatId);
    }
    if (groupChatTo != null) {
      final toUpdated = _addParticipant(groupChatTo, participant);
      await updateData(toUpdated, toUpdated.chatId);
    }
  }

  Chat _addParticipant(GroupChat groupChatTo, Participant participant) =>
      copyChatWith(
        groupChatTo,
        membersIds: groupChatTo.membersIds..add(participant.participantId),
        participants: groupChatTo.participants..add(participant),
        dateOpenedByMembers: groupChatTo.dateOpenedByMembers
          ..[participant.participantId] = Timestamp.now(),
      );

  Chat _removeParticipant(GroupChat groupChatFrom, String participantId) =>
      copyChatWith(
        groupChatFrom,
        membersIds: groupChatFrom.membersIds..remove(participantId),
        dateOpenedByMembers: groupChatFrom.dateOpenedByMembers
          ..remove(participantId),
        participants: groupChatFrom.participants
          ..removeWhere(
            (p) => p.participantId == participantId,
          ),
      );
}

final chatsRepoPvdr = Provider(
  (ref) => ChatsRepository(
    remoteDatabase: RemoteDatabase(
      db: ref.read(databasePvdr),
      collectionPath: 'chats',
      subCollectionPath: 'messages',
      fromMap: (snapshot, _) => chatFromMap(snapshot.data() ?? {}),
      toMap: (chat, _) => chatToMap(chat),
      subFromMap: (snapshot, _) => Message.fromFirestore(snapshot.data() ?? {}),
      subToMap: (message, _) => message.toMap(),
    ),
  ),
);
