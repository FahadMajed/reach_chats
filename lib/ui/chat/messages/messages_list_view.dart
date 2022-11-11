import 'package:flutter/material.dart';
import 'package:reach_chats/chats.dart';
import 'package:reach_chats/ui/chat/messages/widgets/date_info.dart';

import 'widgets/message_bubble.dart';

class MessagesListView extends StatelessWidget {
  final List<ChatElement> chatElements;

  const MessagesListView(
    this.chatElements, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MediaQuery.removePadding(
        removeBottom: true,
        context: context,
        child: ListView(
          reverse: true,
          children: [
            for (final chatElement in chatElements)
              if (chatElement is MessageViewModel)
                MessageBubble(
                  messageViewModel: chatElement,
                )
              else if (chatElement is Date)
                DateInfo(date: chatElement.date)
          ],
        ),
      ),
    );
  }
}
