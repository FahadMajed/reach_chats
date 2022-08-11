import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reach_core/core/core.dart';

import 'chat_export.dart';

class GroupChat extends Chat {
  final List<Participant> participants;

  final String groupName; //research title

  GroupChat({
    String? chatId,
    required Timestamp lastMessageDate,
    required String lastMessage,
    required String lastMessageSenderId,
    required Duration sinceLastMessage,
    required List membersIds,
    int? color,
    required Researcher researcher,
    required List researchsInCommon,
    required int isLastMessageSeen,
    required this.participants,
    required this.groupName,
    required Map<String, dynamic> dateOpenedByMembers,
  }) : super(
          chatId: chatId ?? "",
          researchsInCommon: researchsInCommon,
          membersIds: membersIds,
          researcher: researcher,
          dateOpenedByMembers: dateOpenedByMembers,
          color: color,
          sinceLastMessage: sinceLastMessage,
          isLastMessageSeen: isLastMessageSeen,
          lastMessageDate: lastMessageDate,
          lastMessage: lastMessage,
          lastMessageSenderId: lastMessageSenderId,
          isGroupChat: true,
        );

  Map<String, dynamic> toMap() => {
        "chatId": chatId,
        'isGroupChat': true,
        "researchsInCommon": researchsInCommon,
        "color": color,
        'membersIds': membersIds,
        'participants': participants.map((x) => x.toPartialMap()).toList(),
        'researcher': researcher.toPartialMap(),
        'groupName': groupName,
        "dateOpenedByMembers": dateOpenedByMembers,
        "lastMessageDate": lastMessageDate,
        "lastMessage": lastMessage,
        "lastMessageSenderId": lastMessageSenderId,
      };

  factory GroupChat.fromMap(Map<String, dynamic> data) {
    return GroupChat(
      membersIds: List<dynamic>.from(data['membersIds']),
      participants: List<Participant>.from(
          data['participants']?.map((x) => Participant.fromFirestore(x))),
      researcher: Researcher.fromFirestore(data['researcher']),
      researchsInCommon: data["researchsInCommon"] ?? [],
      groupName: data['groupName'] ?? '',
      chatId: data['chatId'] ?? '',
      color: data["color"] ?? 0xFFB37070,
      dateOpenedByMembers: data["dateOpenedByMembers"] ?? {},
      lastMessageDate: data['lastMessageDate'] ?? Timestamp.now(),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      isLastMessageSeen: (data["dateOpenedByMembers"]
              [data["researcher"]["researcherId"]] as Timestamp)
          .compareTo(data['lastMessageDate']),
      sinceLastMessage: data['lastMessageDate'] == null
          ? Duration()
          : DateTime.now().difference(data['lastMessageDate'].toDate()),
    );
  }

  GroupChat copyWith(
      {List<Participant>? participants,
      String? groupName,
      List? researchsInCommon,
      Researcher? researcher,
      String? chatId,
      List? membersIds,
      int? color,
      int? isLastMessageSeen,
      Timestamp? lastMessageDate,
      String? lastMessage,
      String? lastMessageSenderId,
      Map<String, dynamic>? dateOpenedByMembers,
      Duration? sinceLastMessage}) {
    return GroupChat(
      chatId: chatId ?? this.chatId,
      participants: participants ?? this.participants,
      groupName: groupName ?? this.groupName,
      researcher: researcher ?? this.researcher,
      researchsInCommon: researchsInCommon ?? this.researchsInCommon,
      membersIds: membersIds ?? this.membersIds,
      isLastMessageSeen: isLastMessageSeen ?? this.isLastMessageSeen,
      color: color ?? this.color,
      dateOpenedByMembers: dateOpenedByMembers ?? this.dateOpenedByMembers,
      lastMessageDate: lastMessageDate ?? this.lastMessageDate,
      lastMessage: lastMessage ?? this.lastMessage,
      sinceLastMessage: sinceLastMessage ?? this.sinceLastMessage,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
    );
  }

  void removeMember(String participantId) {
    membersIds.remove(participantId);
    dateOpenedByMembers.remove(participantId);
    participants.removeWhere((p) => p.participantId == participantId);
  }

  void addMember(Participant part) {
    membersIds.add(part.participantId);
    participants.add(part);
    dateOpenedByMembers[part.participantId] = Timestamp.now();
  }
}
