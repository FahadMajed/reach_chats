import 'package:reach_chats/chats.dart';
import 'package:reach_core/core/core.dart';

class SendMessage extends UseCase<void, SendMessageRequest> {
  final ChatsRepository repository;

  SendMessage(this.repository);

  @override
  Future<void> call(SendMessageRequest request) async {
    final timeStamp = Timestamp.now();
    final messageId = Formatter.formatTimeId();
    final chat = request.chat;
    final message = Message(
      messageId: messageId,
      content: request.content,
      fromId: request.fromId,
      toId: chat is PeerChat ? _getToId(chat, request.fromId) : "all",
      timeStamp: timeStamp,
    );

    repository.createMessage(
      chat,
      message,
    );
  }

  String _getToId(PeerChat chat, String fromId) {
    if (fromId == chat.researcher.researcherId) {
      return chat.participant.participantId;
    } else {
      return chat.researcher.researcherId;
    }
  }
}

class SendMessageRequest {
  final String fromId;

  final String content;
  final Chat chat;
  SendMessageRequest({
    required this.fromId,
    required this.content,
    required this.chat,
  });
}

final sendMessagePvdr = Provider<SendMessage>((ref) => SendMessage(
      ref.read(chatsRepoPvdr),
    ));
