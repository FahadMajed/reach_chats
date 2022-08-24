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
  Map<String, dynamic>? dateOpenedByMembers,
  Timestamp? lastMessageDate,
  String? lastMessage,
  String? lastMessageSenderId,
  Duration? sinceLastMessage,
  List<Participant>? participants,
  String? groupName,
  int? color,
}) {
  final newData = {
    'chatId': chatId,
    'participants': participants?.map((e) => e.toPartialMap()).toList(),
    'groupName': groupName,
    'researcher': researcher?.toPartialMap(),
    'researchsInCommon': researchsInCommon,
    'membersIds': membersIds,
    'color': color,
    'dateOpenedByMembers': dateOpenedByMembers,
    'lastMessageDate': lastMessageDate,
    'lastMessage': lastMessage,
    'lastMessageSenderId': lastMessageSenderId,
    'participant': participant?.toPartialMap(),
  };
  return toCopy is GroupChat
      ? toCopy.copyWith(newData)
      : (toCopy as PeerChat).copyWith(newData);
}
