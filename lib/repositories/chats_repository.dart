import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

abstract class IChatsRepository {
  Stream<List<Chat>> streamChats(String userId);

  Stream<List<Message>> streamMessages(String chatId);

  Future<void> createMessage(String chatId, Message m);

  ///we dont want to delete the chat, just remove it
  ///from the research, in case participant was kicked
  ///from a research
  Future<void> removeResearchIdFromChat(
    String chatId,
    String researchId,
  );

  ///add research id to chat, so it chats can be
  ///filtered by research id
  Future<void> addResearchIdToChats(
    String chatId,
    String researchId,
  );
}

class ChatsRepository extends BaseRepository<Chat, Message>
    implements IChatsRepository {
  ChatsRepository({required super.remoteDatabase});

  @override
  Stream<List<Chat>> streamChats(String uid) => streamQuery(remoteDatabase
      .where("membersIds", arrayContains: uid)
      .orderBy("lastMessageDate", descending: true));

  @override
  Future<void> addResearchIdToChats(String chatId, String researchId) async =>
      await updateFieldArrayUnion(chatId, 'researchsInCommon', [researchId]);

  @override
  Future<void> removeResearchIdFromChat(
          String chatId, String researchId) async =>
      await updateFieldArrayRemove(chatId, 'researchsInCommon', [researchId]);

  @override
  Future<void> createMessage(String chatId, Message message) async =>
      await createSubdocument(chatId, message.messageId, message);

  @override
  Stream<List<Message>> streamMessages(String chatId) =>
      streamSubcollectionQuery(
        remoteDatabase
            .getSubCollection(chatId)
            .orderBy('timeStamp', descending: true)
            .limit(50),
      );
}

final chatsRepoPvdr = Provider(
  (ref) => ChatsRepository(
    remoteDatabase: RemoteDatabase(
      db: ref.read(databaseProvider),
      collectionPath: 'chats',
      subCollectionPath: 'messages',
      fromMap: (snapshot, _) => chatFromMap(snapshot.data()!),
      toMap: (chat, _) => chatToMap(chat),
      subFromMap: (snapshot, _) => Message.fromFirestore(snapshot.data() ?? {}),
      subToMap: (message, _) => message.toMap(),
    ),
  ),
);
