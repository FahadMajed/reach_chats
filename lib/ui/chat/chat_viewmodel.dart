import 'package:reach_chats/chats.dart';
import 'package:reach_core/lib.dart';

class ChatViewModel extends Equatable {
  final List<ChatElement> elements;
  final String appBarText;
  final String imageUrl;
  final int peerImageColor;

  const ChatViewModel(
    this.elements, {
    this.appBarText = "  ",
    this.imageUrl = "",
    this.peerImageColor = 0xFFFFFF,
  });

  bool get hasAvatar => imageUrl.isNotEmpty;
  String get textOnAvatar => appBarText.substring(0, 1);

  @override
  List<Object?> get props => [
        elements,
        appBarText,
        imageUrl,
        peerImageColor,
      ];
}

abstract class ChatElement extends Equatable {}

class Date extends ChatElement {
  final String date;

  Date(this.date);

  @override
  List<Object?> get props => [date];
}

class MessageViewModel extends ChatElement {
  final Message message;
  final String sentAt;
  final String senderName;
  final bool fromMe;

  MessageViewModel({
    required this.message,
    required this.sentAt,
    required this.senderName,
    required this.fromMe,
  });

  @override
  List<Object?> get props => [
        message,
        sentAt,
        senderName,
        fromMe,
      ];
}
