import 'package:reach_core/core/core.dart';

import 'message.dart';

class AnnouncementMessage extends Message with NamesParser {
  final List toNames;
  final List toIds;

  AnnouncementMessage({
    this.toNames = const [],
    this.toIds = const [],
    required super.content,
    required super.fromId,
    required super.toId,
    required super.timeStamp,
    required super.messageId,
  });

  factory AnnouncementMessage.fromFirestore(Map<String, dynamic> data) {
    return AnnouncementMessage(
      content: data['content'] ?? '',
      fromId: data['fromId'] ?? '',
      toId: data['toId'] ?? '',
      timeStamp: data['timeStamp'] ?? Timestamp.now(),
      messageId: data['messageId'],
    );
  }

  AnnouncementMessage copyWith2({
    List? toNames,
    List? toIds,
  }) {
    return AnnouncementMessage(
      toNames: toNames ?? this.toNames,
      toIds: toIds ?? this.toIds,
      content: content,
      fromId: fromId,
      messageId: messageId,
      timeStamp: timeStamp,
      toId: toId,
    );
  }

  String get recepients => parseNames(toNames);

  bool contains(String id) => toIds.contains(id);

  AnnouncementMessage addInvitee(String id, String name) =>
      copyWith2(toIds: [...toIds, id], toNames: [...toNames, name]);

  AnnouncementMessage removeInvitee(String id, String name) => copyWith2(
      toIds: toIds.where((currentId) => currentId != id).toList(),
      toNames: toNames.where((currentName) => currentName != name).toList());

  factory AnnouncementMessage.empty() => AnnouncementMessage(
      content: "", fromId: "", toId: "", toIds: [], toNames: [], timeStamp: Timestamp.now(), messageId: "");

  AnnouncementMessage addGroup(String groupId) => copyWith2(toIds: [...toIds, groupId]);

  AnnouncementMessage removeGroup(String groupId) => copyWith2(toIds: [...toIds..remove(groupId)]);

  List<String> getChatsIds(String researcherId) =>
      toIds.map((partId) => Formatter.formatChatId(researcherId, partId)).toList();
}
