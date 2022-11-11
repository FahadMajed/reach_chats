import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

class GroupChat extends Chat {
  final List<Participant> participants;

  final String groupName; //research title
  const GroupChat({
    required this.participants,
    required this.groupName,
    required super.chatId,
    required super.researchsInCommon,
    required super.researcher,
    required super.membersIds,
    required super.color,
    required super.dateOpenedByMembers,
    required super.lastMessage,
  }) : super(isGroupChat: true);

  @override
  String toString() =>
      'GroupChat(participants: $participants, groupName: $groupName)';

  @override
  List<Object?> get props => [
        participants,
        researchsInCommon,
        membersIds,
        color,
        dateOpenedByMembers,
        lastMessage,
        groupName
      ];

  GroupChat copyWith({
    Researcher? researcher,
    List<Participant>? participants,
    String? groupName,
    Map<String, dynamic>? dateOpenedByMembers,
    List? membersIds,
    Message? lastMessage,
  }) {
    return GroupChat(
      participants: participants ?? this.participants,
      groupName: groupName ?? this.groupName,
      chatId: chatId,
      researcher: researcher ?? this.researcher,
      lastMessage: lastMessage ?? this.lastMessage,
      dateOpenedByMembers: dateOpenedByMembers ?? this.dateOpenedByMembers,
      color: color,
      researchsInCommon: researchsInCommon,
      membersIds: membersIds ?? this.membersIds,
    );
  }

  GroupChat removeParticipant(String participantId) => copyChatWith(this,
      participants: participants
        ..removeWhere((p) => p.participantId == participantId),
      membersIds: membersIds..remove(participantId),
      dateOpenedByMembers: dateOpenedByMembers
        ..remove(
          participantId,
        )) as GroupChat;

  GroupChat addParticipant(Participant participant) => copyChatWith(this,
          participants: participants..add(participant),
          membersIds: membersIds..add(participant.participantId),
          dateOpenedByMembers: {
            ...dateOpenedByMembers,
            participant.participantId: DateTime.now()
          }) as GroupChat;

  GroupChat updateParticipant(Participant participant) => copyChatWith(
        this,
        participants: [
          for (final p in participants)
            if (p.participantId == participant.participantId) participant else p
        ],
      ) as GroupChat;
}
