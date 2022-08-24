import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageId;
  final String content;
  final String fromId;
  final String toId;

  final Timestamp timeStamp;

  Message({
    required this.messageId,
    required this.content,
    required this.fromId,
    required this.toId,
    required this.timeStamp,
  });

  factory Message.fromFirestore(Map<String, dynamic> data) {
    return Message(
      messageId: data["messageId"] ?? "",
      content: data['content'] ?? '',
      fromId: data['fromId'] ?? '',
      toId: data['toId'] ?? '',
      timeStamp: data['timeStamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "messageId": messageId,
      'content': content,
      'fromId': fromId,
      'toId': toId,
      'timeStamp': timeStamp,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message &&
        other.content == content &&
        other.fromId == fromId &&
        other.toId == toId &&
        other.timeStamp == timeStamp;
  }

  @override
  int get hashCode {
    return content.hashCode ^
        fromId.hashCode ^
        toId.hashCode ^
        timeStamp.hashCode;
  }

  Message copyWith({
    String? messageId,
    String? content,
    String? fromId,
    String? toId,
    bool? seen,
    Timestamp? timeStamp,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      content: content ?? this.content,
      fromId: fromId ?? this.fromId,
      toId: toId ?? this.toId,
      timeStamp: timeStamp ?? this.timeStamp,
    );
  }

  @override
  String toString() {
    return 'Message(messageId: $messageId, content: $content, fromId: $fromId, toId: $toId, timeStamp: $timeStamp)';
  }
}
