import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

Chat chatFromMap(Map<String, dynamic> data) => data["isGroupChat"] ?? false
    ? ChatMapper.groupFromMap(data)
    : ChatMapper.peerFromMap(data);

Map<String, dynamic> chatToMap(Chat chat) => chat is GroupChat
    ? ChatMapper.groupToMap(chat)
    : ChatMapper.peerToMap(chat as PeerChat);

Chat copyChatWith(
  Chat toCopy, {
  Participant? participant,
  Researcher? researcher,
  String? chatId,
  List? researchsInCommon,
  List? membersIds,
  Map<String, dynamic>? dateOpenedByMembers,
  Message? lastMessage,
  List<Participant>? participants,
  String? groupName,
  int? color,
}) {
  return toCopy is GroupChat
      ? toCopy.copyWith(
          researcher: researcher,
          participants: participants,
          groupName: groupName,
          lastMessage: lastMessage,
          dateOpenedByMembers: dateOpenedByMembers,
          membersIds: membersIds,
        )
      : (toCopy as PeerChat).copyWith(
          participant: participant,
          researcher: researcher,
          lastMessage: lastMessage,
          dateOpenedByMembers: dateOpenedByMembers,
          membersIds: membersIds,
        );
}
