import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

class ChatsRepository
    implements
        DatabaseRepository<Chat>,
        SubCollectionRepository<Message>,
        StreamedRepository<Chat, Message> {
  final FirebaseFirestore _database;
  late CollectionReference<Chat> collection;

  ChatsRepository(this._database) {
    collection = _database.collection("chats").withConverter<Chat>(
          fromFirestore: (snapshot, _) => chatFromMap(snapshot.data()!),
          toFirestore: (chat, _) => chatToMap(chat),
        );
  }

  @override
  Stream<List<Chat>> streamDocuments(String uid) => collection
      .where("membersIds", arrayContains: uid)
      .orderBy("lastMessageDate", descending: true)
      .snapshots()
      .map((list) => list.docs.map((doc) => doc.data()).toList());

  @override
  Future<Chat> createDocument(Chat chat) async =>
      await collection.doc(chat.chatId).set(chat).then((_) => chat);

  @override
  Stream<List<Message>> streamSubCollection(String chatId) => _database
      .collection(FirestorePath.messages(chatId))
      .withConverter<Message>(
          fromFirestore: (snap, _) => Message.fromFirestore(snap.data()!),
          toFirestore: (message, _) => message.toMap())
      .orderBy('timeStamp', descending: true)
      .limit(50)
      .snapshots()
      .map((list) => list.docs.map((messageDoc) => messageDoc.data()).toList());

  @override
  Future<void> createSubDocument(
    String chatId,
    String messageId,
    Message message,
  ) async =>
      await _database
          .collection(FirestorePath.messages(chatId))
          .doc(message.messageId)
          .set(message.toMap());

  @override
  Future<void> updateDocument(Chat chat) async =>
      await collection.doc(chat.chatId).update(chatToMap(chat));

  @override
  Future<void> deleteDocument(String chatId) async =>
      await collection.doc(chatId).delete();

  @override
  Future<Chat> getDocument(String id) async => collection
      .doc(id)
      .get()
      .then((value) => chatFromMap(value.data() as Map<String, dynamic>));

  @override
  Future<void> updateFieldArrayUnion(
    String id,
    String field,
    List union,
  ) async =>
      collection.doc(id).update({field: FieldValue.arrayUnion(union)});

  @override
  Future<void> updateFieldArrayRemove(
    String id,
    String field,
    List remove,
  ) async =>
      collection.doc(id).update({field: FieldValue.arrayRemove(remove)});

  @override
  Future<List<Chat>> getDocuments(String clause, {bool defaultFlow = true}) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateField(String docId, String field, data) {
    throw UnimplementedError();
  }

  @override
  Stream<Chat> streamDocument(String clause) {
    throw UnimplementedError();
  }
}
