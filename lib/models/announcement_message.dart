import 'package:cloud_firestore/cloud_firestore.dart';

import 'message.dart';

class AnnouncementMessage extends Message {
  final List toNames;
  final List toIds;

  AnnouncementMessage({
    this.toNames = const [],
    this.toIds = const [],
    content,
    fromId,
    toId,
    timeStamp,
    messageId,
  }) : super(
          messageId: messageId,
          content: content,
          fromId: fromId,
          toId: "",
          timeStamp: timeStamp,
        );

  factory AnnouncementMessage.fromFirestore(Map<String, dynamic> data) {
    return AnnouncementMessage(
      content: data['content'] ?? '',
      fromId: data['fromId'] ?? '',
      toId: data['toId'] ?? '',
      timeStamp: data['timeStamp'] ?? Timestamp.now(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'content': content,
      'fromId': fromId,
      'toId': toId,
      'timeStamp': timeStamp,
    };
  }

  AnnouncementMessage copyWith2({
    List? toNames,
    List? toIds,
  }) {
    return AnnouncementMessage(
      toNames: toNames ?? this.toNames,
      toIds: toIds ?? this.toIds,
    );
  }
}
