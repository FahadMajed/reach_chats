import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reach_core/core/core.dart';

import 'chat_export.dart';

class PeerChat extends Chat {
  final Participant participant;

  PeerChat({
    required chatId,
    required lastMessageDate,
    required lastMessage,
    required sinceLastMessage,
    required membersIds,
    required researcher,
    required lastMessageSenderId,
    required List researchsInCommon,
    required this.participant,
    isLastMessageSeen,
    required Map<String, dynamic> dateOpenedByMembers,
  }) : super(
            chatId: chatId,
            researcher: researcher,
            membersIds: membersIds,
            isGroupChat: false,
            researchsInCommon: researchsInCommon,
            dateOpenedByMembers: dateOpenedByMembers,
            lastMessageDate: lastMessageDate,
            lastMessage: lastMessage,
            sinceLastMessage: sinceLastMessage,
            lastMessageSenderId: lastMessageSenderId,
            isLastMessageSeen: isLastMessageSeen);

  factory PeerChat.fromMap(Map<String, dynamic> data) {
    return PeerChat(
      participant: Participant.fromFirestore(data['participant']),
      chatId: data['chatId'] ?? '',
      researchsInCommon: data["researchsInCommon"] ?? "",
      membersIds: data["membersIds"] ?? [],
      researcher: Researcher.fromFirestore(data["researcher"]),
      lastMessageDate: data['lastMessageDate'] ?? Timestamp.now(),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      dateOpenedByMembers: data["dateOpenedByMembers"] ?? {},
      isLastMessageSeen: (data["dateOpenedByMembers"]
              [data["researcher"]["researcherId"]] as Timestamp)
          .compareTo(data['lastMessageDate']),
      sinceLastMessage:
          DateTime.now().difference(data['lastMessageDate'].toDate()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "isGroupChat": false,
      "chatId": chatId,
      "researchsInCommon": researchsInCommon,
      "membersIds": membersIds,
      "researcher": researcher.toPartialMap(),
      "participant": participant.toPartialMap(),
      "lastMessageDate": lastMessageDate,
      "lastMessage": lastMessage,
      "dateOpenedByMembers": dateOpenedByMembers,
      "lastMessageSenderId": lastMessageSenderId,
    };
  }

  PeerChat copyWith(
      {Participant? participant,
      Researcher? researcher,
      String? chatId,
      List? researchsInCommon,
      List? membersIds,
      int? isLastMessageSeen,
      Map<String, dynamic>? dateOpenedByMembers,
      Timestamp? lastMessageDate,
      String? lastMessage,
      String? lastMessageSenderId,
      Duration? sinceLastMessage}) {
    return PeerChat(
        chatId: chatId ?? this.chatId,
        participant: participant ?? this.participant,
        researcher: researcher ?? this.researcher,
        researchsInCommon: researchsInCommon ?? this.researchsInCommon,
        membersIds: membersIds ?? this.membersIds,
        isLastMessageSeen: isLastMessageSeen ?? this.isLastMessageSeen,
        dateOpenedByMembers: dateOpenedByMembers ?? this.dateOpenedByMembers,
        lastMessageDate: lastMessageDate ?? this.lastMessageDate,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
        sinceLastMessage: sinceLastMessage ?? this.sinceLastMessage);
  }

  void removeCommonResearch(String researchId) {
    researchsInCommon.remove(researchId);
  }
}
