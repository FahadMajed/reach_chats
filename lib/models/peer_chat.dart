import 'package:reach_core/core/core.dart';

import 'chat_export.dart';

class PeerChat extends Chat {
  PeerChat(Map<String, dynamic> jSON) : super(jSON);

  Participant get participant => Participant(data['participant']);
  int get color => participant.defaultColor;

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        "isGroupChat": false,
        "researcher": researcher.toPartialMap(),
        "participant": participant.toPartialMap(),
        "color": participant.defaultColor,
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
