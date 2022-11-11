import 'package:reach_core/lib.dart';

class Message extends Equatable {
  final String messageId;
  final String content;
  final String fromId;
  final String toId;

  final Timestamp timeStamp;

  const Message({
    required this.messageId,
    required this.content,
    required this.fromId,
    required this.toId,
    required this.timeStamp,
  });

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

  factory Message.init(String researcherId) => Message(
        messageId: Formatter.formatTimeId(),
        content: '',
        fromId: researcherId,
        toId: '',
        timeStamp: Timestamp.now(),
      );

  @override
  List<Object?> get props => [messageId, content, fromId, toId, timeStamp];
}
