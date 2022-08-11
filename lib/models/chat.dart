import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reach_core/core/models/researcher.dart';

class Chat {
  //insert researcher and part object
  final String? chatId;
  final List researchsInCommon;
  final Researcher researcher;

  final bool isGroupChat;

  final List membersIds;
  final Duration sinceLastMessage;
  final int? color;

  final Map<String, dynamic> dateOpenedByMembers;
  final int isLastMessageSeen;
  final Timestamp lastMessageDate;
  final String lastMessage;
  final String lastMessageSenderId;

  Chat(
      {this.chatId,
      required this.researchsInCommon,
      required this.researcher,
      required this.isGroupChat,
      required this.sinceLastMessage,
      this.color,
      required this.membersIds,
      required this.dateOpenedByMembers,
      required this.lastMessageDate,
      required this.lastMessage,
      required this.lastMessageSenderId,
      required this.isLastMessageSeen});

  factory Chat.fromFirestore(Map data) {
    return Chat(
        chatId: data['chatId'] ?? '',
        researcher: Researcher.fromFirestore(data["researcher"]),
        researchsInCommon: data['researchsInCommon'] ?? [],
        isGroupChat: data["isGroupChat"] ?? false,
        membersIds: data["membersIds"] ?? [],
        dateOpenedByMembers: data["dateOpenedByMembers"] ?? {},
        color: data["color"],
        lastMessageDate: data['lastMessageDate'],
        lastMessage: data['lastMessage'] ?? '',
        lastMessageSenderId: data['lastMessageSenderId'] ?? '',
        isLastMessageSeen: data["isLastMessageSeen"] ?? -1,
        sinceLastMessage: DateTime.now().difference(data["lastMessageDate"]));
  }
}
