import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

abstract class ChatsRepository {
  Stream<List<Chat>> streamChats(String userId);

  Stream<List<Message>> streamMessages(String chatId);

  Future<void> createMessage(Chat chat, Message m);

  ///we dont want to delete the chat, just remove it
  ///from the research, in case participant was kicked
  ///from a research
  Future<void> removeResearchIdFromPeerChat(
    String chatId,
    String researchId,
  );

  ///add research id to chat, so it chats can be
  ///filtered by research id
  Future<void> addResearchIdToPeerChat(
    String chatId,
    String researchId,
  );

  Future<void> updateDateOpened(String chatId, String userId);

  Future<void> updateResearcher(String chatId, Researcher updatedResearcher);

  Future<void> createChat(Chat chat);

  Future<void> changeParticipantGroupChat(
    GroupChat? groupChatFrom,
    GroupChat? groupChatTo,
    Participant participant,
  );

  Future<void> removeParticipantFromGroupChat(String groupId, String partId);

  Future<void> removeGroup(String groupId);

  Future<void> updateGroupName(String currentGroupId, String newNameWithTitle);

  Future<void> updateParticipant(String chatId, Participant updatedParticipant);

  Future<void> addParticipantToGroupChat(String groupId, Participant participant);

  Future<List<Message>> getMessagesForChat(String chatId);

  Future<Chat> getChat(String chatId);
}
