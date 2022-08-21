import 'package:reach_core/core/core.dart';

import 'chat_export.dart';

class GroupChat extends Chat {
  GroupChat(Map<String, dynamic> jSON) : super(jSON);

  List<Participant> get participants =>
      (data['participants'] as List).map((e) => Participant(e)).toList();

  String get groupName => data['groupName']; //research title

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        'isGroupChat': true,
        'participants': participants.map((x) => x.toPartialMap()).toList(),
        'researcher': researcher.toPartialMap(),
      };

  @override
  GroupChat copyWith(Map<String, dynamic> newData) => GroupChat(
        {
          ...data,
          ...newData
            ..removeWhere(
              (key, value) => value == false,
            ),
        },
      );

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
