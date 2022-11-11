import 'package:flutter/material.dart';
import 'package:reach_chats/chats.dart';

import 'my_bubble.dart';
import 'peer_bubble.dart';

class MessageBubble extends StatelessWidget {
  final MessageViewModel messageViewModel;

  const MessageBubble({Key? key, required this.messageViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return messageViewModel.fromMe
        ? MyMessageBubble(
            messageViewModel: messageViewModel,
          )
        : PeerMessageBubble(
            messageViewModel: messageViewModel,
          );
  }
}
