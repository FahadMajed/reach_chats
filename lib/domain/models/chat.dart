import 'package:reach_chats/domain/models/message.dart';
import 'package:reach_core/core/core.dart';

abstract class Chat extends Equatable {
  final String chatId;

  final List researchsInCommon;

  final Researcher researcher;

  final bool isGroupChat;

  final List membersIds;

  final int color;

  final Map<String, dynamic> dateOpenedByMembers;

  final Message lastMessage;

  const Chat({
    required this.chatId,
    required this.researchsInCommon,
    required this.researcher,
    required this.isGroupChat,
    required this.membersIds,
    required this.color,
    required this.dateOpenedByMembers,
    required this.lastMessage,
  });

  Duration get sinceLastMessage => DateTime.now().difference(lastMessage.timeStamp.toDate());

  bool isLastMessageSeenByUser(String userId) {
    if ((dateOpenedByMembers[userId] as Timestamp).toDate().isAfter(lastMessage.timeStamp.toDate())) {
      return true;
    }
    return false;
  }
}
