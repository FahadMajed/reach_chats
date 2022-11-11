import 'package:reach_core/core/core.dart';

import 'chat_export.dart';

class PeerChat extends Chat {
  final Participant participant;

  const PeerChat({
    required this.participant,
    required super.chatId,
    required super.researchsInCommon,
    required super.researcher,
    required super.membersIds,
    required super.color,
    required super.dateOpenedByMembers,
    required super.lastMessage,
  }) : super(isGroupChat: false);

  void removeCommonResearch(String researchId) {
    researchsInCommon.remove(researchId);
  }

  @override
  List<Object?> get props => [
        participant,
        researchsInCommon,
        membersIds,
        color,
        dateOpenedByMembers,
        lastMessage,
      ];

  PeerChat copyWith({
    Researcher? researcher,
    Participant? participant,
    Map<String, dynamic>? dateOpenedByMembers,
    List? membersIds,
    Message? lastMessage,
  }) {
    return PeerChat(
      participant: participant ?? this.participant,
      chatId: chatId,
      researcher: researcher ?? this.researcher,
      lastMessage: lastMessage ?? this.lastMessage,
      dateOpenedByMembers: dateOpenedByMembers ?? this.dateOpenedByMembers,
      color: color,
      researchsInCommon: researchsInCommon,
      membersIds: membersIds ?? this.membersIds,
    );
  }

  factory PeerChat.empty() => PeerChat(
      participant: Participant.empty(),
      chatId: '',
      researchsInCommon: [],
      researcher: Researcher.empty(),
      membersIds: [],
      color: 0xFF,
      dateOpenedByMembers: {},
      lastMessage: Message.init(''));
}
