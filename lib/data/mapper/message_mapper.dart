import 'package:reach_chats/domain/models/message.dart';
import 'package:reach_core/lib.dart';

class MessageMapper {
  static Message fromMap(data) {
    //\

    return Message(
      messageId: data['messageId']?.toString() ?? "",
      content: data['content'] ?? "",
      fromId: data['fromId'] ?? "",
      toId: data['toId'] ?? "",
      timeStamp: data['timeStamp'] ?? Timestamp.now(),
    );
  }

  static Map<String, dynamic> toMap(Message message) {
    return {
      'messageId': message.messageId,
      'content': message.content,
      'fromId': message.fromId,
      'toId': message.toId,
      'timeStamp': message.timeStamp,
    };
  }
}
