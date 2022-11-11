import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

class ChatsRepositoryImpl implements ChatsRepository {
  ChatsRepositoryImpl({required RemoteDatabase<Chat, Message> remoteDatabase}) {
    _db = remoteDatabase;
  }

  late final RemoteDatabase<Chat, Message> _db;

  DatabaseQuery<Chat> chatsQuery(String uid) => DatabaseQuery<Chat>(
        [Where("membersIds", arrayContains: uid)],
        orderBy: "lastMessage.timeStamp",
        descending: true,
      );

  @override
  Future<void> createChat(Chat chat) async => await _db.createDocument(
        chat,
        chat.chatId,
      );

  @override
  Stream<List<Chat>> streamChats(String uid) => _db.streamQuery(chatsQuery(uid));

  Future<List<Chat>> fetchChats(String uid) => _db.getQuery(chatsQuery(uid));

  Future<Chat?> fetchChat(String chatId) async => await _db.getDocument(chatId);

  Future<List<Message>> fetchMessagesForChat(String chatId) =>
      _db.getQuerySubcollection(chatId, DatabaseQuery([], orderBy: "timeStamp", descending: true, limit: 50));

  @override
  Future<void> addResearchIdToPeerChat(
    String chatId,
    String researchId,
  ) async =>
      await _db.updateFieldArrayUnion(chatId, 'researchsInCommon', [researchId]);

  @override
  Future<void> removeResearchIdFromPeerChat(String chatId, String researchId) async =>
      await _db.docExists(chatId) ? await _db.updateFieldArrayRemove(chatId, 'researchsInCommon', [researchId]) : null;

  @override
  Future<void> createMessage(Chat chat, Message message) async {
    await _db.createSubdocument(
      parentId: chat.chatId,
      subDocId: message.messageId,
      data: message,
    );

    await _db.updateDocumentRaw({
      'lastMessage': MessageMapper.toMap(message),
      'dateOpenedByMembers': {
        ...chat.dateOpenedByMembers,
        message.fromId: message.timeStamp,
      },
    }, chat.chatId);
  }

  @override
  Stream<List<Message>> streamMessages(String chatId) => _db.streamSubcollectionQuery(
        chatId,
        DatabaseQuery(
          [],
          orderBy: "timeStamp",
          descending: true,
          limit: 50,
        ),
      );

  @override
  Future<void> updateDateOpened(String chatId, String currentUserId) async => await _db.updateField(
        chatId,
        'dateOpenedByMembers.$currentUserId',
        Timestamp.now(),
      );

  @override
  Future<void> updateGroupName(String groupId, String newName) async => await _db.updateField(
        groupId,
        'groupName',
        newName,
      );

  @override
  Future<void> updateParticipant(
    String chatId,
    Participant participant,
  ) async {
    final chat = await _db.getDocument(chatId);
    if (chat is GroupChat) {
      await _db.updateDocument(
          copyChatWith(
            chat,
            participants: [
              for (final part in chat.participants)
                if (part.participantId == participant.participantId) participant else part,
            ],
          ),
          chatId);
    } else {
      await _db.updateField(chatId, 'participant', _participantToPartialMap(participant));
    }
  }

  @override
  Future<void> updateResearcher(
    String chatId,
    Researcher researcher,
  ) async =>
      await _db.updateField(chatId, 'researcher', ResearcherMapper.toPartialMap(researcher));

  @override
  Future<void> addParticipantToGroupChat(
    String groupId,
    Participant participant,
  ) async {
    final groupChatExists = await _db.docExists(groupId);

    groupChatExists
        ? await _db.updateDocumentRaw(
            {
              'participants': _db.arrayUnion([_participantToPartialMap(participant)]),
              'membersIds': _db.arrayUnion([participant.participantId]),
              'dateOpenedByMembers.${participant.participantId}': Timestamp.now(),
            },
            groupId,
          )
        : null;
  }

  @override
  Future<void> removeParticipantFromGroupChat(
    String chatId,
    String participantId,
  ) async {
    final groupChat = await _db.getDocument(chatId) as GroupChat?;

    groupChat != null
        ? await _db.updateDocumentRaw(
            {
              'participants': [
                for (final p in groupChat.participants)
                  if (p.participantId != participantId) _participantToPartialMap(p)
              ],
              'membersIds': _db.arrayRemove([participantId]),
              'dateOpenedByMembers.$participantId': _db.delete(),
            },
            chatId,
          )
        : null;
  }

  Map<String, dynamic> _participantToPartialMap(Participant p) => ParticipantMapper.toPartialMap(p);

  @override
  Future<void> removeGroup(String groupId) async => await _db.deleteDocument(groupId);

  @override
  Future<void> changeParticipantGroupChat(
    GroupChat? groupChatFrom,
    GroupChat? groupChatTo,
    Participant participant,
  ) async {
    final participantId = participant.participantId;

    // we can use the exisitng methods for adding and removing, but we already have
    //the data so we dont want to fetch it agian.

    if (groupChatFrom != null) {
      final fromUpdated = _removeParticipant(groupChatFrom, participantId);
      await _db.updateDocument(fromUpdated, fromUpdated.chatId);
    }
    if (groupChatTo != null) {
      final toUpdated = _addParticipant(groupChatTo, participant);
      await _db.updateDocument(toUpdated, toUpdated.chatId);
    }
  }

  Chat _addParticipant(GroupChat groupChatTo, Participant participant) => copyChatWith(
        groupChatTo,
        membersIds: groupChatTo.membersIds..add(participant.participantId),
        participants: groupChatTo.participants..add(participant),
        dateOpenedByMembers: groupChatTo.dateOpenedByMembers..[participant.participantId] = Timestamp.now(),
      );

  Chat _removeParticipant(GroupChat groupChatFrom, String participantId) => copyChatWith(
        groupChatFrom,
        membersIds: groupChatFrom.membersIds..remove(participantId),
        dateOpenedByMembers: groupChatFrom.dateOpenedByMembers..remove(participantId),
        participants: groupChatFrom.participants
          ..removeWhere(
            (p) => p.participantId == participantId,
          ),
      );

  @override
  Future<Chat> getChat(String chatId) async => await _db.getDocument(chatId);

  @override
  Future<List<Message>> getMessagesForChat(String chatId) async => await _db.getAllSubcollection(chatId);
}

/////////////////////////////

final chatsRepoPvdr = Provider<ChatsRepository>(
  (ref) => ChatsRepositoryImpl(
    remoteDatabase: FirestoreRemoteDatabase<Chat, Message>(
      db: ref.read(databasePvdr),
      collectionPath: 'chats',
      subCollectionPath: 'messages',
      fromMap: (snapshot, _) => chatFromMap(snapshot.data() ?? {}),
      toMap: (chat, _) => chatToMap(chat),
      subFromMap: (snapshot, _) => MessageMapper.fromMap(snapshot.data() ?? {}),
      subToMap: (message, _) => MessageMapper.toMap(message),
    ),
  ),
);
