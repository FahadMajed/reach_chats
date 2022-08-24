import 'package:reach_core/core/core.dart';

import 'chat_export.dart';

class PeerChat extends Chat {
  PeerChat(Map<String, dynamic> jSON) : super(jSON);

  Participant get participant => Participant(data['participant']);

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        "isGroupChat": false,
        "researcher": researcher.toPartialMap(),
        "participant": participant.toPartialMap(),
      };

  @override
  PeerChat copyWith(Map<String, dynamic> newData) => PeerChat(
        {
          ...data,
          ...newData
            ..removeWhere(
              (key, value) => value == null,
            ),
        },
      );

  void removeCommonResearch(String researchId) {
    researchsInCommon.remove(researchId);
  }

  @override
  List<Object?> get props => [toMap()];
}
