import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

Chat chatFromMap(Map<String, dynamic> data) => data["isGroupChat"] ?? false
    ? GroupChat.fromMap(data)
    : PeerChat.fromMap(data);

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
        ? toCopy.copyWith(
            chatId: chatId ?? toCopy.chatId,
            participants: participants ?? toCopy.participants,
            groupName: groupName ?? toCopy.groupName,
            researcher: researcher ?? toCopy.researcher,
            researchsInCommon: researchsInCommon ?? toCopy.researchsInCommon,
            membersIds: membersIds ?? toCopy.membersIds,
            isLastMessageSeen: isLastMessageSeen ?? toCopy.isLastMessageSeen,
            color: color ?? toCopy.color,
            dateOpenedByMembers:
                dateOpenedByMembers ?? toCopy.dateOpenedByMembers,
            lastMessageDate: lastMessageDate ?? toCopy.lastMessageDate,
            lastMessage: lastMessage ?? toCopy.lastMessage,
            lastMessageSenderId:
                lastMessageSenderId ?? toCopy.lastMessageSenderId,
          )
        : (toCopy as PeerChat).copyWith(
            chatId: chatId ?? toCopy.chatId,
            participant: participant ?? (toCopy).participant,
            researcher: researcher ?? toCopy.researcher,
            researchsInCommon: researchsInCommon ?? toCopy.researchsInCommon,
            membersIds: membersIds ?? toCopy.membersIds,
            isLastMessageSeen: isLastMessageSeen ?? toCopy.isLastMessageSeen,
            dateOpenedByMembers:
                dateOpenedByMembers ?? toCopy.dateOpenedByMembers,
            lastMessageDate: lastMessageDate ?? toCopy.lastMessageDate,
            lastMessage: lastMessage ?? toCopy.lastMessage,
            lastMessageSenderId:
                lastMessageSenderId ?? toCopy.lastMessageSenderId,
          );
