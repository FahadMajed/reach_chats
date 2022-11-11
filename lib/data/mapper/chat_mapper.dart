import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

class ChatMapper {
  static PeerChat peerFromMap(data) {
    return PeerChat(
      participant: ParticipantMapper.fromMap(data['participant']),
      chatId: data['chatId'] ?? "",
      researchsInCommon: data['researchsInCommon'],
      researcher: ResearcherMapper.fromMap(data['researcher']),
      membersIds: data['membersIds'],
      color: data['color'],
      dateOpenedByMembers: data['dateOpenedByMembers'],
      lastMessage: MessageMapper.fromMap(data['lastMessage']),
    );
  }

  static GroupChat groupFromMap(data) {
    return GroupChat(
      participants: ParticipantMapper.fromMapList(data),
      chatId: data['chatId'] ?? "",
      researchsInCommon: data['researchsInCommon'],
      researcher: ResearcherMapper.fromMap(data['researcher']),
      membersIds: data['membersIds'],
      color: data['color'],
      dateOpenedByMembers: data['dateOpenedByMembers'],
      lastMessage: MessageMapper.fromMap(data['lastMessage']),
      groupName: data['groupName'] ?? "",
    );
  }

  static Map<String, dynamic> peerToMap(PeerChat chat) {
    return {
      'participant': ParticipantMapper.toPartialMap(chat.participant),
      'chatId': chat.chatId,
      'researchsInCommon': chat.researchsInCommon,
      'researcher': ResearcherMapper.toPartialMap(chat.researcher),
      'isGroupChat': chat.isGroupChat,
      'membersIds': chat.membersIds,
      'color': chat.color,
      'dateOpenedByMembers': chat.dateOpenedByMembers,
      'lastMessage': MessageMapper.toMap(chat.lastMessage),
    };
  }

  static Map<String, dynamic> groupToMap(GroupChat chat) {
    return {
      'participants': ParticipantMapper.toMapList(chat.participants),
      'chatId': chat.chatId,
      'researchsInCommon': chat.researchsInCommon,
      'researcher': ResearcherMapper.toPartialMap(chat.researcher),
      'isGroupChat': chat.isGroupChat,
      'membersIds': chat.membersIds,
      'color': chat.color,
      'dateOpenedByMembers': chat.dateOpenedByMembers,
      'lastMessage': MessageMapper.toMap(chat.lastMessage),
      'groupName': chat.groupName
    };
  }
}
