import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

Chat chatFromMap(Map<String, dynamic> data) =>
    data["isGroupChat"] ?? false ? GroupChat(data) : PeerChat(data);

Map<String, dynamic> chatToMap(Chat chat) =>
    chat is GroupChat ? chat.toMap() : (chat as PeerChat).toMap();

Chat copyChatWith(
  Chat toCopy, {
  Participant? participant,
  Researcher? researcher,
  String? chatId,
  List? researchsInCommon,
  List? membersIds,
  int? isLastMessageSeen,
  Map<String, dynamic>? dateOpenedByMembers,
  Timestamp? lastMessageDate,
  String? lastMessage,
  String? lastMessageSenderId,
  Duration? sinceLastMessage,
  List<Participant>? participants,
  String? groupName,
  int? color,
}) =>
    toCopy is GroupChat
        ? toCopy.copyWith({
            'chatId': chatId,
            'participants': participants,
            'groupName': groupName,
            'researcher': researcher,
            'researchsInCommon': researchsInCommon,
            'membersIds': membersIds,
            'isLastMessageSeen': isLastMessageSeen,
            'color': color,
            'dateOpenedByMembers': dateOpenedByMembers,
            'lastMessageDate': lastMessageDate,
            'lastMessage': lastMessage,
            'lastMessageSenderId': lastMessageSenderId,
          })
        : (toCopy as PeerChat).copyWith(
            {
              'chatId': chatId,
              'participant': participant,
              'groupName': groupName,
              'researcher': researcher,
              'researchsInCommon': researchsInCommon,
              'membersIds': membersIds,
              'isLastMessageSeen': isLastMessageSeen,
              'color': color,
              'dateOpenedByMembers': dateOpenedByMembers,
              'lastMessageDate': lastMessageDate,
              'lastMessage': lastMessage,
              'lastMessageSenderId': lastMessageSenderId,
            },
          );
